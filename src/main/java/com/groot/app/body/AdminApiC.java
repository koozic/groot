package com.groot.app.body;

import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

/**
 * 관리자 AJAX 전용 API
 * <p>
 * GET  /admin/api?action=get&suppId=1   → 영양소 단건 조회 (수정 폼 pre-fill용)
 * POST /admin/api?action=insert         → 영양소 등록
 * POST /admin/api?action=update         → 영양소 수정
 * POST /admin/api?action=delete         → 영양소 삭제
 */
@WebServlet(name = "AdminApiC", value = "/admin/api")
public class AdminApiC extends HttpServlet {

    private final AdminDAO dao = new AdminDAO();
    private final Gson gson = new Gson();

    /**
     * 관리자 세션 검증
     */
    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    }

    // ── GET: 수정 폼용 단건 조회 ──
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"권한 없음\"}");
            return;
        }

        try {
            int suppId = Integer.parseInt(req.getParameter("suppId"));
            BodyDTO dto = dao.getSupplementById(suppId);
            out.print(dto != null ? gson.toJson(dto) : "{\"error\":\"not found\"}");
        } catch (Exception e) {
            resp.setStatus(500);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    // ── POST: insert / update / delete ──
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        if (!isAdmin(req)) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\":false,\"message\":\"권한 없음\"}");
            return;
        }

        String action = req.getParameter("action");
        Map<String, Object> result = new HashMap<>();

        try {
            switch (action == null ? "" : action) {

                case "insert": {
                    BodyDTO dto = buildDto(req);
                    dao.insertSupplement(dto);  // dto.supplementId가 시퀀스로 세팅됨

                    String bodyIdParam = req.getParameter("bodyId");
                    if (bodyIdParam != null && !bodyIdParam.isEmpty()) {
                        dao.linkBodySupplement(
                                Integer.parseInt(bodyIdParam), dto.getSupplementId()
                        );
                    }
                    result.put("success", true);
                    result.put("message", "등록 완료");
                    result.put("suppId", dto.getSupplementId());
                    break;
                }

                case "update": {
                    BodyDTO dto = buildDto(req);
                    dto.setSupplementId(Integer.parseInt(req.getParameter("suppId")));
                    dao.updateSupplement(dto);
                    result.put("success", true);
                    result.put("message", "수정 완료");
                    break;
                }

                case "delete": {
                    String idStr = req.getParameter("suppId");
                    if (idStr == null || idStr.isEmpty()) {
                        result.put("success", false);
                        result.put("message", "suppId 누락");
                        break;
                    }
                    int suppId = Integer.parseInt(idStr);
                    dao.deleteBodySupplementLinks(suppId);
                    dao.deleteSupplementLikes(suppId);
                    dao.deleteSupplement(suppId);
                    result.put("success", true);
                    result.put("message", "삭제 완료");
                    break;
                }

                default:
                    result.put("success", false);
                    result.put("message", "알 수 없는 action: " + action);
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", e.getMessage());
        }

        out.print(gson.toJson(result));
    }

    private BodyDTO buildDto(HttpServletRequest req) {
        BodyDTO dto = new BodyDTO();
        dto.setSupplementName(req.getParameter("supplementName"));
        dto.setSupplementEfficacy(req.getParameter("supplementEfficacy"));
        dto.setSupplementDosage(req.getParameter("supplementDosage"));
        dto.setSupplementTiming(req.getParameter("supplementTiming"));
        dto.setSupplementCaution(req.getParameter("supplementCaution"));
        dto.setSupplementImagePath(req.getParameter("supplementImagePath"));
        return dto;
    }
}