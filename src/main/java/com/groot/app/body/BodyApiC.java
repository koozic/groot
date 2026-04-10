package com.groot.app.body;

import com.google.gson.Gson;
import com.groot.app.user.UserDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AJAX 전용 API 서블릿
 * <p>
 * GET  /body?action=list              → 신체 부위 목록 (JSON)
 * GET  /body?action=supps&bodyId=1    → 신체별 영양소 목록 (JSON)
 * GET  /body?action=detail&suppId=5   → 영양소 상세 (JSON)
 * GET  /body?action=myLikes           → 마이페이지 좋아요 목록 (JSON)
 * POST /body?action=like&suppId=5     → 좋아요 토글 (JSON)
 */
@WebServlet(name = "BodyApiC", value = "/body")
public class BodyApiC extends HttpServlet {

    private final BodyDAO dao = new BodyDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String action = request.getParameter("action");
        PrintWriter out = response.getWriter();

        try {
            switch (action == null ? "" : action) {

                // ── 신체 부위 전체 목록 ──
                case "list": {
                    List<BodyDTO> bodies = dao.getAllBodies();
                    out.print(gson.toJson(bodies));
                    break;
                }

                // ── 신체 부위별 영양소 리스트 ──
                case "supps": {
                    String bodyIdParam = request.getParameter("bodyId");
                    if (bodyIdParam == null || bodyIdParam.trim().isEmpty()) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.print("{\"error\":\"bodyId가 필요합니다.\"}");
                        break;
                    }
                    int bodyId = Integer.parseInt(bodyIdParam);
                    String sort = request.getParameter("sort");
                    if (sort == null || sort.isEmpty()) sort = "recent";

                    List<BodyDTO> supps = dao.getSupplementsByBody(bodyId, sort);
                    out.print(gson.toJson(supps));
                    break;
                }

                // ── 영양소 상세 조회 + 조회수 증가 ──
                case "detail": {
                    String suppIdParam = request.getParameter("suppId");
                    if (suppIdParam == null || suppIdParam.isEmpty()) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.print("{\"error\":\"suppId 필요\"}");
                        break;
                    }
                    int suppId = Integer.parseInt(suppIdParam);
                    BodyDTO detail = dao.getSupplementDetail(suppId);

                    if (detail == null) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.print("{\"error\":\"not found\"}");
                    } else {
                        out.print(gson.toJson(detail));
                    }
                    break;
                }

                // ── 마이페이지 좋아요 목록 ──
                case "myLikes": {
                    HttpSession session = request.getSession(false);
                    UserDTO user = (session != null)
                            ? (UserDTO) session.getAttribute("loginUser") : null;

                    if (user == null) {
                        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                        out.print("{\"error\":\"login required\"}");
                        break;
                    }
                    String sort = request.getParameter("sort");
                    if (sort == null) sort = "recent";

                    List<BodyDTO> liked = dao.getLikedSupplements(user.getUser_id(), sort);
                    out.print(gson.toJson(liked));
                    break;
                }

                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"unknown action\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"서버 오류: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String action = request.getParameter("action");
        PrintWriter out = response.getWriter();

        try {
            // ── 좋아요 토글 ──
            if ("like".equals(action)) {
                HttpSession session = request.getSession(false);
                UserDTO user = (session != null)
                        ? (UserDTO) session.getAttribute("loginUser") : null;

                if (user == null) {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    out.print("{\"liked\":false,\"error\":\"login required\"}");
                    return;
                }
                int suppId = Integer.parseInt(request.getParameter("suppId"));
                boolean liked = dao.toggleSupplementLike(user.getUser_id(), suppId);

                Map<String, Object> result = new HashMap<>();
                result.put("liked", liked);
                out.print(gson.toJson(result));
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}