package com.groot.app.body;

import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * 관리자 서블릿
 * <p>
 * GET  /admin               → 관리자 메인 페이지 (영양소 목록, 정렬 지원)
 * GET  /admin?action=form   → 신규 등록 폼
 * GET  /admin?action=form&suppId=1 → 수정 폼
 * POST /admin?action=insert → 영양소 등록
 * POST /admin?action=update → 영양소 수정
 * POST /admin?action=delete → 영양소 삭제
 */
@WebServlet(name = "AdminC", value = "/admin")
public class AdminC extends HttpServlet {

    private final AdminDAO dao = new AdminDAO();
    private final Gson gson = new Gson();

    /**
     * 관리자 세션 검증
     */
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        return Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 관리자 아닌 경우 차단
        if (!isAdmin(request)) {
            response.sendRedirect("login_view");
            return;
        }

        String action = request.getParameter("action");

        // ── action 없음 → 관리자 메인 (영양소 전체 목록) ──
        if (action == null || action.isEmpty()) {
            try {
                // 정렬 파라미터 (없으면 기본값 "id_desc")
                String sortBy = request.getParameter("sortBy");
                if (sortBy == null || sortBy.isEmpty()) sortBy = "id_desc";

                List<BodyDTO> list = dao.getAllSupplements(sortBy);

                request.setAttribute("suppList", list);
                request.setAttribute("sortBy", sortBy);   // JSP 셀렉트 selected 표시용
                request.setAttribute("activeTab", "admin");
                request.setAttribute("content", "body/admin_main.jsp");

                request.getRequestDispatcher("index.jsp").forward(request, response);

            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(500, "목록 조회 실패: " + e.getMessage());
            }
            return;
        }

        // ── action=form → 등록 or 수정 폼 ──
        if ("form".equals(action)) {
            String suppIdParam = request.getParameter("suppId");
            try {
                if (suppIdParam != null && !suppIdParam.isEmpty()) {
                    // 수정: 기존 데이터 불러오기
                    int suppId = Integer.parseInt(suppIdParam);
                    BodyDTO dto = dao.getSupplementById(suppId);
                    request.setAttribute("supp", dto);  // 폼에서 ${supp.xxx} 로 사용
                }
                // 등록: supp=null → 폼에서 빈 칸으로 표시됨

                request.setAttribute("activeTab", "admin");
                request.setAttribute("content", "body/admin_form.jsp");

                request.getRequestDispatcher("index.jsp").forward(request, response);

            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(500, "폼 조회 실패: " + e.getMessage());
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 관리자 아닌 경우 차단
        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            switch (action == null ? "" : action) {

                // ── 영양소 등록 ──
                case "insert": {
                    BodyDTO dto = buildDtoFromRequest(request);
                    dao.insertSupplement(dto);

                    String bodyIdParam = request.getParameter("bodyId");
                    if (bodyIdParam != null && !bodyIdParam.isEmpty()) {
                        dao.linkBodySupplement(
                                Integer.parseInt(bodyIdParam), dto.getSupplementId()
                        );
                    }
                    response.sendRedirect("admin");
                    break;
                }

                // ── 영양소 수정 ──
                case "update": {
                    BodyDTO dto = buildDtoFromRequest(request);
                    dto.setSupplementId(Integer.parseInt(request.getParameter("suppId")));
                    dao.updateSupplement(dto);
                    response.sendRedirect("admin");
                    break;
                }

                // ── 영양소 삭제 ──
                case "delete": {
                    String suppIdStr = request.getParameter("suppId");
                    if (suppIdStr == null || suppIdStr.isEmpty()) {
                        response.sendError(
                                HttpServletResponse.SC_BAD_REQUEST, "삭제할 영양소 ID가 없습니다."
                        );
                        return;
                    }
                    int suppId = Integer.parseInt(suppIdStr);
                    dao.deleteBodySupplementLinks(suppId);
                    dao.deleteSupplementLikes(suppId);
                    dao.deleteSupplement(suppId);
                    response.sendRedirect("admin");
                    break;
                }

                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "처리 실패: " + e.getMessage());
        }
    }

    /**
     * 폼 파라미터 → BodyDTO 변환 공통 메서드
     */
    private BodyDTO buildDtoFromRequest(HttpServletRequest request) {
        BodyDTO dto = new BodyDTO();
        dto.setSupplementName(request.getParameter("supplementName"));
        dto.setSupplementEfficacy(request.getParameter("supplementEfficacy"));
        dto.setSupplementDosage(request.getParameter("supplementDosage"));
        dto.setSupplementTiming(request.getParameter("supplementTiming"));
        dto.setSupplementCaution(request.getParameter("supplementCaution"));
        dto.setSupplementImagePath(request.getParameter("supplementImagePath"));
        return dto;
    }
}