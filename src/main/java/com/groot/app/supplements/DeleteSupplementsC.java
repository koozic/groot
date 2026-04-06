package com.groot.app.supplements;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "DeleteSupplementsC", value = "/deleteSupplement")
public class DeleteSupplementsC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // DAO에게 삭제를 시킵니다. (MovieDAO의 delMovie와 같은 역할)
            // 이때 JSP가 보낸 ?id=123 값을 DAO가 읽을 수 있도록 request를 통째로 넘깁니다.
            SupplementsDAO.SDAO.delSupplement(request);

            // 삭제가 끝났으면? 다시 리스트 화면으로 돌아가야겠죠!
            // "나 다 지웠으니까, 다시 영양성분 리스트(가상주소) 보여줘!"라고 시킵니다.
            response.sendRedirect("supplements");
    }
}
