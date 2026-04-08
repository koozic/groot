// =========================================================
// ✍️ 1. 리뷰 비동기 등록 컨트롤러 (페이지 안 넘어가게 처리!)
// =========================================================
package com.groot.app.review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "ReviewWriteC", value = "/review-write")
public class ReviewWriteC extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. 주방장(DAO)한테 박스 통째로 넘기기 (DB 저장)
        ReviewDAO.RDAO.insertReview(request);

        // 2. 🌟 비동기(Ajax) 통신 핵심!
        // 원래는 response.sendRedirect()로 페이지를 튕겨냈지만,
        // 이제는 화면이 넘어가지 않게 "1"이라는 글자만 브라우저로 쏴줍니다.
        response.setContentType("text/plain; charset=utf-8");
        response.getWriter().print("1");
    }
}