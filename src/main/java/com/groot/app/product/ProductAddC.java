package com.groot.app.product;

import com.groot.app.user.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ProductAddC", value = "/product-add")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10

)
public class ProductAddC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!UserDAO.isAdmin(request)) {
            // 관리자가 아니면 403 에러를 던지거나 경고창 후 메인으로 리다이렉트
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자만 접근 가능합니다.");
            return; // 로직 중단
        }
// 아래는 실제 관리자 기능 로직...


        // 1. Cloudinary에 이미지 업로드 후 URL 반환
        String imgUrl = com.groot.app.common.CloudinaryUtil.uploadFromRequest(request, "productImage", "products");

        // 2. 반환된 URL을 Request에 저장 (DAO로 전달하기 위함)
        if (imgUrl != null) {
            request.setAttribute("productImage", imgUrl);
        }

        //일
        ProductDAO.PDAO.productAdd(request);


        //어디로?
        response.sendRedirect("product?insert=success");
    }

    public void destroy() {
    }
}