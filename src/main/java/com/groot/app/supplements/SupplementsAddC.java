package com.groot.app.supplements;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "supplementAddC", value = "/supplementAdd")
public class SupplementsAddC extends HttpServlet {

    // 화면 조회 (리스트 보기)
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 메뉴바 불 들어오게 설정
        request.setAttribute("activeTab", "nutrition");

        // "알맹이 페이지로 supplements_reg.jsp를 써라!"라고 지정
        request.setAttribute("content", "supplements/supplements_reg.jsp");

        // 메인 페이지(index.jsp)로 보냅니다.
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

    }

    public void destroy() {
    }
}
