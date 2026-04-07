package com.groot.app.supplements;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "UpdateSupplementsC", value = "/updateSupplement")
public class UpdateSupplementsC extends HttpServlet {

    // 화면 조회 (리스트 보기)
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // DAO에 있는 상세 조회 메서드(기존 데이터를 하나 불러오는 기능)를 그대로 재사용
        SupplementsDAO.SDAO.getSupplementDetail(request);

        // 수정용 JSP 페이지로 포워딩
        request.setAttribute("content", "supplements/supplements_update.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

    }

    public void destroy() {
    }
}
