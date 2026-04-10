package com.groot.app.cart;

import com.google.gson.Gson;
import com.groot.app.user.UserDTO;
import com.groot.app.user.UserDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 관심제품(장바구니) Controller
 *
 * [GET]  /cart            → 장바구니 페이지 (로그인 필요)
 * [POST] /cart/add        → 담기 AJAX
 * [POST] /cart/remove     → 빼기 AJAX
 * [POST] /cart/toggle     → 찜 토글 AJAX (찜버튼용)
 * [GET]  /cart/list       → 내 목록 JSON 반환 AJAX
 */
@WebServlet(urlPatterns = {"/cart", "/cart/add", "/cart/remove", "/cart/toggle", "/cart/list"})
public class FavoriteServlet extends HttpServlet {

    private final FavoriteService service = new FavoriteService();
    private final Gson gson = new Gson();

    // ── GET 요청 ─────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uri = req.getRequestURI();

        // /cart/list → JSON 반환
        if (uri.endsWith("/cart/list")) {
            handleList(req, resp);
            return;
        }

        // /cart → 장바구니 페이지
        // 비로그인이면 로그인 페이지로
        HttpSession session  = req.getSession(false);
        UserDTO loginUser = session != null ? (UserDTO) session.getAttribute("loginUser") : null;

        if (loginUser == null) {
            resp.sendRedirect("login");
            return;
        }

        List<FavoriteVO> list = service.getMyFavorites(loginUser.getUser_id());
        req.setAttribute("favoriteList", list);
        req.setAttribute("content",   "views/favorite/cartList.jsp");
        req.setAttribute("activeTab", "cart");
        req.getRequestDispatcher("index.jsp").forward(req, resp);
    }

    // ── POST 요청 ────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        PrintWriter out = resp.getWriter();

        // 로그인 확인
        HttpSession session  = req.getSession(false);
        UserDTO loginUser = session != null ? (UserDTO) session.getAttribute("loginUser") : null;

        if (loginUser == null) {
            out.print(gson.toJson(Map.of("success", false, "message", "로그인이 필요해요")));
            return;
        }

        // 요청 body 파싱
        Map<String, Object> body = parseBody(req);
        String uri = req.getRequestURI();

        try {
            if (uri.endsWith("/cart/add")) {
                handleAdd(loginUser.getUser_id(), body, out, req);

            } else if (uri.endsWith("/cart/remove")) {
                handleRemove(loginUser.getUser_id(), body, out, req);

            } else if (uri.endsWith("/cart/toggle")) {
                handleToggle(loginUser.getUser_id(), body, out, req);
            }

        } catch (Exception e) {
            out.print(gson.toJson(Map.of("success", false, "message", "서버 오류")));
            e.printStackTrace();
        }
    }

    // ── 담기 ────────────────────────────────────
    private void handleAdd(String userId, Map<String, Object> body, PrintWriter out, HttpServletRequest req) {
        int productId = ((Number) body.get("productId")).intValue();

        String result = service.addFavorite(userId, productId);
        int    count  = service.getFavoriteCount(userId);

        // 🌟 2. 추가: 세션의 장바구니 개수 최신화
        req.getSession().setAttribute("cartCount", count);

        Map<String, Object> res = new HashMap<>();
        switch (result) {
            case "added":
                res.put("success", true);
                res.put("message", "장바구니에 담았어요 🛒");
                res.put("cartCount", count);
                break;
            case "already":
                res.put("success", false);
                res.put("message", "이미 담긴 제품이에요");
                res.put("cartCount", count);
                break;
            default:
                res.put("success", false);
                res.put("message", "오류가 발생했어요");
        }
        out.print(gson.toJson(res));
    }

    // ── 빼기 ────────────────────────────────────
    private void handleRemove(String userId, Map<String, Object> body, PrintWriter out, HttpServletRequest req) {
        long favoriteId = ((Number) body.get("cartId")).longValue();

        boolean ok    = service.removeFavorite(favoriteId, userId);
        int     count = service.getFavoriteCount(userId);

        // 🌟 추가: 세션의 장바구니 개수 최신화
        req.getSession().setAttribute("cartCount", count);

        Map<String, Object> res = new HashMap<>();
        res.put("success",   ok);
        res.put("cartCount", count);
        res.put("message",   ok ? "삭제했어요" : "오류가 발생했어요");
        out.print(gson.toJson(res));
    }

    // ── 찜 토글 ─────────────────────────────────
    private void handleToggle(String userId, Map<String, Object> body, PrintWriter out, HttpServletRequest req) {
        int    productId = ((Number) body.get("productId")).intValue();
        String result    = service.toggleFavorite(userId, productId);
        int    count     = service.getFavoriteCount(userId);

        // 🌟 추가: 세션의 장바구니 개수 최신화
        req.getSession().setAttribute("cartCount", count);

        Map<String, Object> res = new HashMap<>();
        res.put("success",   !result.equals("error"));
        res.put("action",    result);   // "added" or "removed"
        res.put("cartCount", count);
        out.print(gson.toJson(res));
    }

    // ── 목록 JSON 반환 ───────────────────────────
    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session  = req.getSession(false);
        UserDTO loginUser = session != null ? (UserDTO) session.getAttribute("loginUser") : null;

        if (loginUser == null) {
            out.print(gson.toJson(Map.of("success", false, "message", "로그인 필요")));
            return;
        }

        List<FavoriteVO> list = service.getMyFavorites(loginUser.getUser_id());

        Map<String, Object> res = new HashMap<>();
        res.put("success", true);
        res.put("list",    list);
        res.put("count",   list.size());
        out.print(gson.toJson(res));
    }

    // ── 요청 body JSON 파싱 ──────────────────────
    private Map<String, Object> parseBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        String line;
        try (BufferedReader br = req.getReader()) {
            while ((line = br.readLine()) != null) sb.append(line);
        }
        return gson.fromJson(sb.toString(), Map.class);
    }
}
