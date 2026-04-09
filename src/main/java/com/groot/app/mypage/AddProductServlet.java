package com.groot.app.mypage;

import com.groot.app.user.UserDTO;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

// JS의 fetch('mypage/add-product') 주소와 매핑됩니다.
@WebServlet("/mypage/add-product")
public class AddProductServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 1. 세션에서 로그인 유저 ID 가져오기
        UserDTO loginUser = (com.groot.app.user.UserDTO) request.getSession().getAttribute("loginUser");

        // 로그인 안 된 상태면 에러 반환(401)
        if (loginUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String userId = loginUser.getUser_id();
        int productId = Integer.parseInt(request.getParameter("productId"));

        // 2. DAO 호출하여 DB에 저장
        boolean isSuccess = MyPageDAO.MDAO.addMyProduct(userId, productId);

        // 3. 성공 여부에 따라 HTTP 상태 코드 반환
        if (isSuccess) {
            response.setStatus(HttpServletResponse.SC_OK); // 200 (성공 -> js에서 response.ok = true)
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // 500 (실패)
        }
    }
}