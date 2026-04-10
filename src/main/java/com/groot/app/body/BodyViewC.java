package com.groot.app.body;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * GET /body_view → body/body.jsp 로 포워딩만 담당
 * index.jsp의 <jsp:include> 구조에서는 이 서블릿 없이
 * 바로 body.jsp를 include 할 수 있으나,
 * /body_view URL로 직접 접근할 경우를 대비해 유지합니다.
 */
@WebServlet(name = "BodyViewC", value = "/body_view")
public class BodyViewC extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // index.jsp가 content 속성으로 이 JSP를 include 하므로
        // 서블릿은 단순히 포워딩만 합니다.
        request.setAttribute("activeTab", "recommend"); // 네비 활성화용
        request.setAttribute("content", "body/body.jsp"); // ← 추가
        request.getRequestDispatcher("index.jsp").forward(request, response);
        // ↑ index.jsp 에서 <jsp:include page="${content}"/> 로 body.jsp를 포함시키려면
        //   아래처럼 content 속성을 세팅한 뒤 index.jsp로 포워딩해야 합니다.
        // request.setAttribute("content", "body/body.jsp");
        // request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}