package com.groot.app.product;

import com.groot.app.user.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ProductDelC", value = "/product-del")
public class ProductDelC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        if (!UserDAO.isAdmin(request)) {
            // 관리자가 아니면 403 에러를 던지거나 경고창 후 메인으로 리다이렉트
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자만 접근 가능합니다.");
            return; // 로직 중단
        }


        //일
        ProductDAO.PDAO.productDelete(request);


        //어디로?
        response.sendRedirect("product?delete=success");


    }




    public void destroy() {
    }
}