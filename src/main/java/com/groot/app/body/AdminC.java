package com.groot.app.body;

import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminC", value = "/admin")
public class AdminC extends HttpServlet {

    private final AdminDAO dao = new AdminDAO();
    private final Gson gson = new Gson();

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        return Boolean.TRUE.equals(session.getAttribute("isAdmin"));
    }

    // ✅ JSON 응답 공통 메서드
    private void sendJson(HttpServletResponse response, Map<String, Object> result) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(gson.toJson(result));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String action = request.getParameter("action");

        // ✅ 단건 조회 (모달용)
        if ("getOne".equals(action)) {
            Map<String, Object> result = new HashMap<>();
            try {
                int suppId = Integer.parseInt(request.getParameter("suppId"));
                BodyDTO dto = dao.getSupplementById(suppId);

                result.put("success", true);
                result.put("data", dto);

            } catch (Exception e) {
                result.put("success", false);
                result.put("message", e.getMessage());
            }
            sendJson(response, result);
            return;
        }

        // 👉 기존 JSP 이동은 유지 (관리자 페이지)
        try {
            String sortBy = request.getParameter("sortBy");
            if (sortBy == null) sortBy = "id_desc";

            List<BodyDTO> list = dao.getAllSupplements(sortBy);

            request.setAttribute("suppList", list);
            request.setAttribute("content", "body/admin_main.jsp");
            request.getRequestDispatcher("index.jsp").forward(request, response);

        } catch (Exception e) {
            response.sendError(500);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8"); // 반드시 getParameter 호출 전에 수행
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> result = new HashMap<>();

        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.put("success", false);
            result.put("message", "관리자 권한 없음");
            sendJson(response, result);
            return;
        }

        try {
            // 🔥 JSON 데이터를 Map으로 변환
            Gson gson = new Gson();
            Map<String, Object> jsonMap = gson.fromJson(request.getReader(), Map.class);

            String action = (String) jsonMap.get("action");

            switch (action) {
                case "insert": {
                    BodyDTO dto = buildDtoFromMap(jsonMap);
                    dao.insertSupplement(dto);

                    if (jsonMap.get("bodyId") != null && !jsonMap.get("bodyId").toString().isEmpty()) {
                        int bodyId = (int) Double.parseDouble(jsonMap.get("bodyId").toString());
                        dao.linkBodySupplement(bodyId, dto.getSupplementId());
                    }
                    result.put("success", true);
                    result.put("message", "등록 완료");
                    break;
                }

                case "update": {
                    BodyDTO dto = buildDtoFromMap(jsonMap);
                    int suppId = (int) Double.parseDouble(jsonMap.get("suppId").toString());
                    dto.setSupplementId(suppId);
                    dao.updateSupplement(dto);
                    result.put("success", true);
                    result.put("message", "수정 완료");
                    break;
                }

                case "delete": {
                    int suppId = (int) Double.parseDouble(jsonMap.get("suppId").toString());
                    dao.deleteBodySupplementLinks(suppId);
                    dao.deleteSupplementLikes(suppId);
                    dao.deleteSupplement(suppId);
                    result.put("success", true);
                    result.put("message", "삭제 완료");
                    break;
                }
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }
        sendJson(response, result);
    }

    // 🔥 Helper 메서드 추가
    private BodyDTO buildDtoFromMap(Map<String, Object> map) {
        BodyDTO dto = new BodyDTO();
        dto.setSupplementName((String) map.get("supplementName"));
        dto.setSupplementEfficacy((String) map.get("supplementEfficacy"));
        dto.setSupplementDosage((String) map.get("supplementDosage"));
        dto.setSupplementTiming((String) map.get("supplementTiming"));
        dto.setSupplementCaution((String) map.get("supplementCaution"));
        dto.setSupplementImagePath((String) map.get("supplementImagePath"));
        return dto;
    }
}