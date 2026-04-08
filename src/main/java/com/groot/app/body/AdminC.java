package com.groot.app.body;

import com.google.gson.Gson;
import com.groot.app.body.BodyDTO;


import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * 관리자 서블릿
 * <p>
 * GET  /admin            → 관리자 메인 페이지 (영양소 목록)
 * GET  /admin?action=form&suppId=1  → 수정 폼 (suppId 없으면 신규 등록 폼)
 * POST /admin?action=insert  → 영양소 등록
 * POST /admin?action=update  → 영양소 수정
 * POST /admin?action=delete  → 영양소 삭제
 */
@WebServlet(name = "AdminC", value = "/admin")
public class AdminC extends HttpServlet {

    private final AdminDAO dao = new AdminDAO();
    private final Gson gson = new Gson();


    // ✅ 수정: admin 테이블 기준으로 세션 키 변경
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;

        // 통합 세션 체크: "user"라는 키로 저장된 객체를 가져옴
        Object userObj = session.getAttribute("user");

        if (userObj != null && userObj instanceof com.groot.app.user.UserDTO) {
            com.groot.app.user.UserDTO user = (com.groot.app.user.UserDTO) userObj;

            // UserDTO의 아이디 필드명이 user_id라면 getUser_id(), userId라면 getUserId() 사용
            // 앞서 발생한 에러를 고려하여 본인의 DTO 필드명에 맞게 호출하세요.
            String userId = user.getUser_id(); // 예시: 실제 필드명에 맞출 것

            return "admin".equals(userId); // 아이디가 admin이면 관리자로 인정
        }
        return false;
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

        // action 없음 → 관리자 메인 (영양소 전체 목록)
        if (action == null || action.isEmpty()) {
            try {
                List<BodyDTO> list = dao.getAllSupplements();
                request.setAttribute("suppList", list);
                request.getRequestDispatcher("body/admin_main.jsp")
                        .forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(500, "목록 조회 실패: " + e.getMessage());
            }
            return;
        }

        // action=form → 등록 or 수정 폼
        if ("form".equals(action)) {
            String suppIdParam = request.getParameter("suppId");
            try {
                if (suppIdParam != null && !suppIdParam.isEmpty()) {
                    // 수정: 기존 데이터 불러오기
                    int suppId = Integer.parseInt(suppIdParam);
                    BodyDTO dto = dao.getSupplementById(suppId);
                    request.setAttribute("supp", dto);   // 폼에서 ${supp.xxx} 로 사용
                }
                // 등록: supp=null → 폼에서 빈 칸으로 표시됨
                request.getRequestDispatcher("body/admin_form.jsp")
                        .forward(request, response);
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

                    // 등록 후 어떤 body에 연결할지 처리
                    String bodyIdParam = request.getParameter("bodyId");
                    if (bodyIdParam != null && !bodyIdParam.isEmpty()) {
                        int bodyId = Integer.parseInt(bodyIdParam);
                        // 방금 등록한 supplement의 ID를 DAO에서 시퀀스로 가져와 연결
                        dao.linkBodySupplement(bodyId, dto.getSupplementId());
                    }

                    response.sendRedirect("admin"); // 목록으로 이동
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

                    // ✅ 방어 로직 추가: 값이 없으면 에러 처리 후 메서드 종료
                    if (suppIdStr == null || suppIdStr.isEmpty()) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "삭제할 영양소 ID가 없습니다.");
                        return;
                    }

                    int suppId = Integer.parseInt(suppIdStr);

                    // 연결 테이블 먼저 삭제 (FK 제약 때문에)
                    dao.deleteBodySupplementLinks(suppId);
                    // 좋아요도 삭제
                    dao.deleteSupplementLikes(suppId);
                    // 영양소 본체 삭제
                    dao.deleteSupplement(suppId);

                    // 삭제 후 원래 있던 곳으로 돌아가기 위해 referer(이전 페이지)를 확인하거나
                    // 추천 화면 주소로 직접 보냅니다.
                    response.sendRedirect("body_view");
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

    // 폼 파라미터 → BodyDTO 변환 공통 메서드
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

