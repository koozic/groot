package com.groot.app.mypage;

import com.groot.app.user.UserDTO;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/mypage/remove-product")
public class DeleteProductServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        UserDTO loginUser = (com.groot.app.user.UserDTO) request.getSession().getAttribute("loginUser");

        if (loginUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String userId = loginUser.getUser_id();
        int productId = Integer.parseInt(request.getParameter("productId"));

        // DAO 삭제 메서드 호출
        boolean isSuccess = MyPageDAO.MDAO.removeMyProduct(userId, productId);

        if (isSuccess) {
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}