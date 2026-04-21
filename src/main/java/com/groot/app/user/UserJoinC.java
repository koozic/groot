package com.groot.app.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "UserJoinC", value = "/join")

// 이미지 넣기 위해 필요!
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10
)

public class UserJoinC extends HttpServlet {

    private void renderJoinPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("content", "user/join.jsp");
        request.setAttribute("activeTab", "join");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        renderJoinPage(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {


        // 우리가 보낸 파일을 url형태로 바꿔줌.
        String imgUrl = com.groot.app.common.CloudinaryUtil.uploadFromRequest(req, "user_profile", "user");
        System.out.println("[UserJoinC] imgUrl=" + imgUrl);
//url 주소를 가져오는 행위

        if (imgUrl != null) { //널이 아니면 파일을 입력했다 > 그러면 싫어주겠다
            req.setAttribute("user_profile", imgUrl);
        }

        UserDAO.join(req);


        Boolean redirectJoin = (Boolean) req.getAttribute("redirectJoin");
        if (redirectJoin != null && redirectJoin) {
            renderJoinPage(req, resp);
        } else {
            resp.sendRedirect("hello-servlet");
        }
    }

    public void destroy() {
    }
}
