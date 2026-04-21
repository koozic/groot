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
        // 프론트엔드(자바스크립트)가 이미 데이터를 다 가지고 있으므로 DB 조회를 생략합니다!
        // SupplementsDAO.SDAO.getSupplementDetail(request);

        // getRequestDispatcher() : request를 지정된 경로의 파일로 전달하기 위해 목적지를 설정하는 메서드
        request.getRequestDispatcher("supplements/supplements_detail.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

    }

    public void destroy() {
    }
}
