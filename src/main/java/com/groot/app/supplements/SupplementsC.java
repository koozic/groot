package com.groot.app.supplements;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "SupplementsC", value = "/supplements")
public class SupplementsC extends HttpServlet {

    // 화면 조회 (리스트 보기)
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // 1. 가져온 데이터를 list라는 변수(바구니)에 제대로 담아주고,
        List<SupplementsDTO> list = SupplementsDAO.SDAO.getSupplementsList();
        // 2. 그 바구니를 화면(JSP)으로 보냅니다.
        request.setAttribute("supplementsList", list);

        // 👇 네비게이션 메뉴 활성화 처리
        request.setAttribute("activeTab", "nutrition");

        // 2. 화면 포워딩
        request.setAttribute("content", "supplements/supplements.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }


    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // DAO의 등록 메서드 실행
        SupplementsDAO.SDAO.addSupplement(request);

        // 등록이 끝나면 다시 리스트 화면(doGet)으로 새로고침
        response.sendRedirect("supplements");
    }

    public void destroy() { }

}
