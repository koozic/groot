package com.groot.app.user;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;

@WebServlet(name = "UserJoinC", value = "/join")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10

)
public class UserJoinC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {



       response.sendRedirect("user/join.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        Part profile = req.getPart("user_profile");

        String imgUrl = com.groot.app.common.CloudinaryUtil.uploadFile(profile, "user");

        if (imgUrl != null) {
            req.setAttribute("user_profile", imgUrl);
        }



        UserDAO.join(req);


        Boolean redirectJoin = (Boolean) req.getAttribute("redirectJoin");
        if (redirectJoin != null && redirectJoin) {
            resp.sendRedirect("user/join.jsp");
        } else {
            resp.sendRedirect("index.jsp");
        }



    }

    public void destroy() {
    }
}