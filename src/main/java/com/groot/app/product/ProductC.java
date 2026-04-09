package com.groot.app.product;

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

        // 1. 파라미터 확인
        String nutrientId = request.getParameter("nutrientId");

        // 2. 파라미터 유무에 따른 DAO 메서드 분기
        if (nutrientId != null && !nutrientId.isEmpty()) {
            ProductDAO.PDAO.showProductsByNutrient(request, nutrientId);
        } else {
            ProductDAO.PDAO.showAllProducts(request);
        }

        ArrayList<NutrientDTO> nutrients = ProductDAO.PDAO.getAllNutrients(request);
        request.setAttribute("nutrients", nutrients);

        request.getRequestDispatcher("product/product.jsp").forward(request, response);

    }


    public void destroy() {
    }
}