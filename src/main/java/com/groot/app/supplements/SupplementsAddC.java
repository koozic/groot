package com.groot.app.supplements;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "supplementAddC", value = "/supplementAdd")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10
)

public class SupplementsAddC extends HttpServlet {

    // 화면 조회 (리스트 보기)
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 메뉴바 불 들어오게 설정
        // request.setAttribute("activeTab", "nutrition");

        // 등록 화면을 모달창(비동기 통신)으로 띄우기 위해서 주석처리
        // "알맹이 페이지로 supplements_reg.jsp를 써라!"라고 지정
        // request.setAttribute("content", "supplements/supplements_reg.jsp");
        // 메인 페이지(index.jsp)로 보냅니다.
        // request.getRequestDispatcher("/index.jsp").forward(request, response);

        // 뼈대(index.jsp)를 거치지 않고, 곧바로 등록 폼 껍데기만 던져줌!
        request.getRequestDispatcher("supplements/supplements_reg.jsp").forward(request, response);
    }
    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

    }

    public void destroy() {
    }
}
