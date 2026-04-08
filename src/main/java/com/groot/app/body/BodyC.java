package com.groot.app.body;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.google.gson.Gson;
import javax.servlet.ServletException;
import javax.servlet.http.HttpSession;
import java.io.PrintWriter;
import java.util.*;

/**
 * BodyC - 신체 부위 / 영양소 관련 AJAX 요청 처리
 *
 * URL 패턴별 action 구분:
 *  GET  /body?action=list               → 모든 신체 부위 목록
 *  GET  /body?action=supps&bodyId=1&sort=view  → 신체별 영양소 리스트
 *  GET  /body?action=detail&suppId=5    → 영양소 상세 (조회수 증가)
 *  POST /body?action=like&suppId=5      → 좋아요 토글 (로그인 필요)
 *  GET  /body?action=myLikes&sort=recent → 마이페이지 좋아요 목록
 */

@WebServlet(name = "BodyC", value = {"/body", "/body_view"})
public class BodyC extends HttpServlet {

    private final BodyDAO dao = new BodyDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
        String uri = request.getRequestURI();
        String action = request.getParameter("action"); // action 파라미터를 먼저 받습니다.

        // 페이지 요청인 경우 (AJAX가 아님) 단순 페이지 이동 (action이 없을 때만 실행)
        if (uri.contains("body_view") && action == null) {
            request.getRequestDispatcher("body/body.jsp").forward(request, response);
            return;
        }
        // 2. 여기서부터는 AJAX 또는 상세페이지 이동 처리
            request.setCharacterEncoding("UTF-8");
        // action에 따라 컨텐츠 타입을 결정 (detail은 HTML, 나머지는 JSON)
            response.setContentType("application/json; charset=UTF-8");

        if ("detail".equals(action)) {
            response.setContentType("text/html; charset=UTF-8");
        } else {
            response.setContentType("application/json; charset=UTF-8");
        }

            PrintWriter out = response.getWriter();

            try {
                // action이 null일 경우 빈 문자열로 처리하여 에러 방지
                switch (action == null ? "" : action) {

                    // ── 신체 부위 전체 목록 ──
                    case "list": {
                        // 신체 부위 목록 (BodyDTO 리스트)
                        List<BodyDTO> bodies = dao.getAllBodies();
                        out.print(gson.toJson(bodies));
                        break;
                    }

                    // ── 신체 부위별 영양소 리스트(AJAX용) ──
                    case "supps": {
                        String bodyIdParam = request.getParameter("bodyId");

                        // ✅ bodyId가 null이거나 빈 문자열인 경우 방어 처리
                        if (bodyIdParam == null || bodyIdParam.trim().isEmpty()) {
                            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                            out.print("{\"error\":\"bodyId가 필요합니다.\"}");
                            break;
                        }

                        int bodyId = Integer.parseInt(bodyIdParam); // 이제 안전하게 파싱 가능
                        String sort = request.getParameter("sort");
                        if (sort == null || sort.isEmpty()) sort = "recent";

                        List<BodyDTO> supps = dao.getSupplementsByBody(bodyId, sort);
                        System.out.println("조회된 개수: " + supps.size()); // 0보다 커야 합니다!
                        out.print(gson.toJson(supps));
                        break;
                    }

                    // ── 영양소 상세 조회(페이지 이동용) + 조회수 증가 ──
                    case "detail": {
                        // 영양소 상세 보기 (이때 DAO에서 view_count +1 로직이 실행되어야 함)
                        int suppId = Integer.parseInt(request.getParameter("suppId"));

                        // 2. DAO를 통해 상세 정보 및 조회수 증가 처리
                        // ✅ DAO의 3번 메서드 호출 (상세정보 + 조회수 증가)
                        BodyDTO detail = dao.getSupplementDetail(suppId);

                        if (detail == null) {
                            // 데이터가 없을 경우 404 에러 페이지나 메시지 처리
                            response.sendError(HttpServletResponse.SC_NOT_FOUND, "해당 영양소 정보를 찾을 수 없습니다.");
                            out.print("{\"error\":\"not found\"}");
                        } else {
                            // ⚠️ 중요: JSON 응답이 아니라 JSP로 포워딩합니다.
                            request.setAttribute("d", detail);
                            request.getRequestDispatcher("body/supplement_detail.jsp").forward(request, response);
                        }
                        break;

                    }

                    // ── 마이페이지 좋아요 목록 ──
                    case "myLikes": {
                        // 마이페이지 좋아요 목록 조회 (로그인 체크 필수)
                        HttpSession session = request.getSession(false);
                        // 세션의 userId 타입(String/NUMBER) 확인 필요. 여기서는 String 기준
                        if (session == null || session.getAttribute("userId") == null) {
                            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                            out.print("{\"error\":\"login required\"}");
                            break;
                        }
                        String userId = (String) session.getAttribute("userId");
                        String sort = request.getParameter("sort"); // "recent" or "popular"
                        if (sort == null) sort = "recent";

                        List<BodyDTO> liked = dao.getLikedSupplements(userId, sort);
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
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String action = req.getParameter("action");
        PrintWriter out = resp.getWriter();

        try {
            // ── 영양소 좋아요 토글 ──
            if ("like".equals(action)) {
                HttpSession session = req.getSession(false);
                if (session == null || session.getAttribute("userId") == null) {
                    resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    out.print("{\"liked\":false,\"error\":\"login required\"}");
                    return;
                }
                String userId = (String) session.getAttribute("userId");
                int suppId = Integer.parseInt(req.getParameter("suppId"));

                // DAO에서 좋아요 여부를 확인해 없으면 Insert, 있으면 Delete 후 현재 상태 리턴
                boolean liked = dao.toggleSupplementLike(userId, suppId);

                // 직접 문자열을 만드는 것보다 Map을 이용해 JSON으로 만드는 것이 안전함
                Map<String, Object> resultMap = new HashMap<>();
                resultMap.put("liked", liked);
                out.print(gson.toJson(resultMap));
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    public void destroy() {
    }
}