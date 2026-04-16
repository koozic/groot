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

        String cmd = request.getParameter("cmd"); // 비동기 데이터 요청 판별용, list라는 글자가 들어가있음 물음표가 뒤가 파라미터

        // 1. [비동기 AJAX 요청] 순수 상품 데이터(JSON)만 필요할 때
        if ("list".equals(cmd)) {
            String nutrientId = request.getParameter("nutrientId");

            // 1. 프론트엔드에서 넘어온 page 파라미터를 읽고 정수로 변환 (값이 없으면 기본값 1)
            String pageStr = request.getParameter("page");
            int page = (pageStr != null && !pageStr.isEmpty()) ? Integer.parseInt(pageStr) : 1;

            // 2. DAO 호출 시 생성된 page 변수 전달
            if (nutrientId != null && !nutrientId.isEmpty()) {
                // 주의: 이 메서드 내부에도 페이징 처리가 필요합니다.
                ProductDAO.PDAO.showProductsByNutrient(request, nutrientId, page);
            } else {
                ProductDAO.PDAO.showAllProducts(request, page);
            }

            Object products = request.getAttribute("products");

            response.setContentType("application/json; charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(products));

            return;
        }
    // 경용님 코드병경
        ArrayList<NutrientDTO> nutrients = ProductDAO.PDAO.getAllNutrients(request);
        request.setAttribute("nutrients", nutrients);
        request.setAttribute("content", "product/product.jsp");
        request.setAttribute("activeTab", "product");
        request.getRequestDispatcher("index.jsp").forward(request, response);

    }


    
    public void destroy() {
    }
}
