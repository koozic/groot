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

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // 1. static 메서드이므로 new 없이 바로 호출!
        // DAO가 DB에서 가져온 영양성분 리스트를 변수에 받습니다.
        List<SupplementsDTO> supplementsList = SupplementsDAO.getSupplementsList();

        // 2. 받아온 리스트를 컨트롤러가 직접 request 객체에 담습니다.
        // JSP 화면에서 <c:forEach items="${sList}"> 로 꺼내 쓸 수 있게 됩니다.
        request.setAttribute("supplementsList", supplementsList);

        // 3. 화면 포워딩
        request.setAttribute("content", "jsp/supplements/supplements.jsp");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

    }

    public void destroy() {
    }
}
