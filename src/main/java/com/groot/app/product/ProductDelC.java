package com.groot.app.product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ProductDelC", value = "/product-del")
public class ProductDelC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        //일
        ProductDAO.PDAO.productDelete(request);

        //어디로?
        response.sendRedirect("product");

    }




    public void destroy() {
    }
}