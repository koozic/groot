package com.groot.app.cart;

import com.google.gson.Gson;
import com.groot.app.user.UserDTO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;

@WebServlet(urlPatterns = {"/cart","/cart/list","/cart/add","/cart/remove","/cart/toggle","/cart/merge"})
public class FavoriteServlet extends HttpServlet {
    private final FavoriteService service = new FavoriteService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getRequestURI().endsWith("/cart/list")) { handleList(req, resp); return; }
        UserDTO u = getLoginUser(req);
        if (u == null) { resp.sendRedirect("user-Login"); return; }
        List<FavoriteVO> list = service.getMyFavorites(u.getUser_id());
        CartUtil.refreshCartCount(req.getSession(), u.getUser_id());
        req.setAttribute("favoriteList", list);
        req.setAttribute("content", "cart/cart.jsp");
        req.setAttribute("activeTab", "cart");
        req.getRequestDispatcher("index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String uri = req.getRequestURI();
        if (uri.endsWith("/cart/merge")) { handleMerge(req, out); return; }
        UserDTO u = getLoginUser(req);
        if (u == null) { out.print(gson.toJson(Map.of("success",false,"message","로그인이 필요해요"))); return; }
        Map<String,Object> body = parseBody(req);
        try {
            if      (uri.endsWith("/cart/add"))    handleAdd   (req, u.getUser_id(), body, out);
            else if (uri.endsWith("/cart/remove")) handleRemove(req, u.getUser_id(), body, out);
            else if (uri.endsWith("/cart/toggle")) handleToggle(req, u.getUser_id(), body, out);
        } catch (Exception e) { out.print(gson.toJson(Map.of("success",false,"message","서버 오류"))); e.printStackTrace(); }
    }

    private void handleAdd(HttpServletRequest req, String userId, Map<String,Object> body, PrintWriter out) {
        int productId = ((Number) body.get("productId")).intValue();
        String result = service.addFavorite(userId, productId);
        CartUtil.refreshCartCount(req.getSession(), userId);
        int count = service.getFavoriteCount(userId);
        Map<String,Object> res = new HashMap<>();
        res.put("cartCount", count);
        switch(result) {
            case "added":   res.put("success",true);  res.put("message","장바구니에 담았어요 🛒"); break;
            case "already": res.put("success",false); res.put("message","이미 담긴 제품이에요"); break;
            default:        res.put("success",false); res.put("message","오류가 발생했어요");
        }
        out.print(gson.toJson(res));
    }

    private void handleRemove(HttpServletRequest req, String userId, Map<String,Object> body, PrintWriter out) {
        long favoriteId = ((Number) body.get("cartId")).longValue();
        boolean ok = service.removeFavorite(favoriteId, userId);
        CartUtil.refreshCartCount(req.getSession(), userId);
        int count = service.getFavoriteCount(userId);
        out.print(gson.toJson(Map.of("success",ok,"cartCount",count,"message",ok?"삭제했어요":"오류")));
    }

    private void handleToggle(HttpServletRequest req, String userId, Map<String,Object> body, PrintWriter out) {
        int productId = ((Number) body.get("productId")).intValue();
        String result = service.toggleFavorite(userId, productId);
        CartUtil.refreshCartCount(req.getSession(), userId);
        int count = service.getFavoriteCount(userId);
        out.print(gson.toJson(Map.of("success",!result.equals("error"),"action",result,"cartCount",count)));
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();
        UserDTO u = getLoginUser(req);
        if (u == null) { out.print(gson.toJson(Map.of("success",false))); return; }
        List<FavoriteVO> list = service.getMyFavorites(u.getUser_id());
        out.print(gson.toJson(Map.of("success",true,"list",list,"count",list.size())));
    }

    private void handleMerge(HttpServletRequest req, PrintWriter out) {
        UserDTO u = getLoginUser(req);
        if (u == null) { out.print(gson.toJson(Map.of("success",false))); return; }
        Map<String,Object> body = parseBody(req);
        String localJson = (String) body.get("localCart");
        CartUtil.mergeLocalCart(req.getSession(), localJson, u.getUser_id());
        int count = service.getFavoriteCount(u.getUser_id());
        out.print(gson.toJson(Map.of("success",true,"cartCount",count,"message","장바구니가 합쳐졌어요 🛒")));
    }

    private UserDTO getLoginUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null ? (UserDTO) s.getAttribute("loginUser") : null;
    }

    private Map<String,Object> parseBody(HttpServletRequest req) {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = req.getReader()) { String l; while((l=br.readLine())!=null) sb.append(l); }
        catch (IOException e) { e.printStackTrace(); }
        try { return gson.fromJson(sb.toString(), Map.class); }
        catch (Exception e) { return new HashMap<>(); }
    }
}
