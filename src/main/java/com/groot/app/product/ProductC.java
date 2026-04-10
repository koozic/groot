package com.groot.app.product;

import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "ProductC", value = "/product")
public class ProductC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String cmd = request.getParameter("cmd"); // 비동기 데이터 요청 판별용

        // 1. [비동기 AJAX 요청] 순수 상품 데이터(JSON)만 필요할 때
        if ("list".equals(cmd)) {
            String nutrientId = request.getParameter("nutrientId");

            // 기존 DAO 그대로 사용 (request 영역에 "products"로 담김)
            if (nutrientId != null && !nutrientId.isEmpty()) {
                ProductDAO.PDAO.showProductsByNutrient(request, nutrientId);
            } else {
                ProductDAO.PDAO.showAllProducts(request);
            }

            // request에서 꺼내서 JSON으로 변환 후 바로 응답 (화면 포워딩 X)
            Object products = request.getAttribute("products");

            response.setContentType("application/json; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(products));

            return; // ★ 여기서 메서드를 종료하여 아래의 화면 포워딩 로직을 타지 않게 함
        }



        ArrayList<NutrientDTO> nutrients = ProductDAO.PDAO.getAllNutrients(request);
        request.setAttribute("nutrients", nutrients);

        // 변경된 코드 (수정 후)
// 1. index.jsp의 <jsp:include> 영역에 삽입될 타겟 JSP 경로 지정
        request.setAttribute("content", "product/product.jsp");

// 2. UI 처리를 위한 activeTab 플래그 전달 (선택 사항이나 권장됨)
        request.setAttribute("activeTab", "product");

// 3. 최종적으로 레이아웃 템플릿인 index.jsp로 포워딩
        request.getRequestDispatcher("index.jsp").forward(request, response);

    }


    public void destroy() {
    }
}