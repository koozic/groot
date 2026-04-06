package com.groot.app.review;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

// 🌟 무영아! 에러 안 나려면 이거 꼭 있어야 돼! (JSON 변환기)
import com.google.gson.Gson;

@WebServlet(name = "ReviewC", value = "/review")
public class ReviewC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // 1. 공통: 어떤 상품인지 번호 먼저 받기! (기본값 101)
        String pIdStr = request.getParameter("PRODUCT_ID");
        int pId = (pIdStr != null) ? Integer.parseInt(pIdStr) : 101;

        // 🌟 2. 경찰의 검문: "너 비밀 손님(Ajax)이야?"
        String ajaxHeader = request.getHeader("X-Requested-With");

        if ("XMLHttpRequest".equals(ajaxHeader)) {
            // ========================================================
            // 🛸 [구역 A] 비밀 손님 (Ajax 정렬 버튼 눌렀을 때)
            // ========================================================
            response.setContentType("application/json; charset=UTF-8"); // "데이터 줄게!"

            // JS가 보낸 '정렬 방식'이랑 '별점' 확인
            String sortType = request.getParameter("sortType");
            String starFilterStr = request.getParameter("starFilter");
            int starFilter = (starFilterStr != null) ? Integer.parseInt(starFilterStr) : 0;

            // DAO 일 시켜서 데이터 가져오기
            ReviewDAO.RDAO.getAllReview(request, pId, sortType, starFilter);
            ArrayList<ReviewDTO> reviews = (ArrayList<ReviewDTO>) request.getAttribute("reviews");

            // 🌟 마법의 도구(GSON)로 리스트를 JSON 문자로 바꿔서 던져줌!
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(reviews));

            return; // 🌟 멈춰! JSP로 안 넘어가고 여기서 끝냄! (매우 중요)
        }

        // ========================================================
        // 🚗 [구역 B] 일반 손님 (처음 주소창 치고 들어왔을 때)
        // ========================================================

        // 1. 포토 갤러리에 띄울 '사진들' 쫙 뽑아오기!
        ArrayList<ReviewDTO> photoImages = ReviewDAO.RDAO.getAllPhotoImages(pId);
        request.setAttribute("allPhotoImages", photoImages);

        // 2. 리뷰 리스트 뽑아오기 (기본값: 최신순, 모든별점)
        ReviewDAO.RDAO.getAllReview(request, pId, "date", 0);

        // 3. 3.9점 같은 별점 통계 데이터 뽑기
        ReviewDAO.getReviewStats(request, pId);

        // 4. JSP 화면으로 보내주기!
        request.setAttribute("content", "review/review.jsp");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}