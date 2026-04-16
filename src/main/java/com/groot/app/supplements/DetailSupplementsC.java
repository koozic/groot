package com.groot.app.supplements;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "DetailSupplementsC", value = "/detailSupplements")

public class DetailSupplementsC extends HttpServlet {

    // 화면 조회 (리스트 보기)
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // [비즈니스 로직] 클릭한 영양성분 '하나'만 조회하는 일 시키기
        // 자바스크립트, 모달 활용해서 보여줄 거라서 주석처리
        // SupplementsDAO.SDAO.getSupplementDetail(request);

        // getRequestDispatcher() : request를 지정된 경로의 파일로 전달하기 위해 목적지를 설정하는 메서드
        request.getRequestDispatcher("supplements/supplements_detail.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

    }

    public void destroy() {
    }
}
