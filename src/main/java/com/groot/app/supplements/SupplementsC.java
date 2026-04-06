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

        // 1. 싱글톤 객체(SDAO)를 통해 전체 리스트 조회 메서드 호출!
        // (메서드 이름은 회원님이 DAO에 만드신 이름으로 적어주세요. 예: getSupplementsList 또는 selectAllSupplements)
        SupplementsDAO.SDAO.getSupplementsList();

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

    public void destroy() {
    }
}
