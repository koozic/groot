package com.groot.app.product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ProductEditC", value = "/product-edit")
public class ProductEditC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        //일
        ProductDAO.PDAO.showProductDetail(request);
//        ProductDAO.PDAO.productEdit(request);
        //학원 파일 확인해서 체크하기 edit update 부분

        //어디로?
//        response.sendRedirect("product/product_edit.jsp");
        request.getRequestDispatcher("product/product_edit.jsp").forward(request, response);
    }

    public  void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        ProductDAO.PDAO.productEdit(request);


        String id = ProductDAO.PDAO.productEdit(request);
        request.setCharacterEncoding("UTF-8");
        // 3. Redirect 사용하여 GET 방식으로 상세 페이지 호출
        // 이렇게 하면 ProductDetailC의 doGet이 실행되므로 405 에러가 발생하지 않습니다.
        response.sendRedirect("product-detail?id=" + id);

    }


    public void destroy() {
    }
}