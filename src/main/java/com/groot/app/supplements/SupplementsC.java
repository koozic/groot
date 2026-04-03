package com.groot.app.supplements;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

// // 1. 브라우저에서 /supplements 로 접속하면 이 서블릿이 실행됩니다.
@WebServlet(name = "SupplementsC", value = "/supplements")
public class SupplementsC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // 2. DAO를 생성하고 DB에서 영양성분 리스트를 가져옵니다.
        // 컨트롤러가 흐름을 제어하는 총책임자로서
        // DAO(주방장) 객체를 생성(new SupplementDAO())하여 일을 시키고,
        // 그 결과물만 JSP에 전달하는 구조
        SupplementsDAO dao = new SupplementsDAO();
//        List<SupplementsDTO> supplementList = dao.getSupplementsList();
        SupplementsDAO.getSupplementsList();

        // 3. 가져온 리스트를 'request' 객체에 담습니다.
        // JSP에서 "sList"라는 이름으로 이 데이터를 꺼낼 수 있게 됩니다.
        request.setAttribute("sList", supplementList);

        // 4. 데이터를 가지고 리스트 화면(JSP)으로 이동합니다. (RequestDispatcher 사용)
        RequestDispatcher dispatcher = request.getRequestDispatcher("supplementList.jsp");
        dispatcher.forward(request, response);

    }

    public void destroy() {
    }
}
