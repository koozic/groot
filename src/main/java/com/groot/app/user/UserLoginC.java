package com.groot.app.user;

import com.groot.app.cart.CartUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "UserLoginC", value = "/user-Login")
public class UserLoginC extends HttpServlet {

    private void renderLoginPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("content", "user/login.jsp");
        req.setAttribute("activeTab", "login");
        req.getRequestDispatcher("index.jsp").forward(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        renderLoginPage(req, resp);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        boolean isSuccess = UserDAO.Login(request);

        if (isSuccess) {
            UserDTO loginUser = (UserDTO) request.getSession().getAttribute("loginUser");
            if (loginUser != null) {
                CartUtil.refreshCartCount(request.getSession(), loginUser.getUser_id());
            }

            String redirect = request.getParameter("redirect");
            if (redirect != null && !redirect.trim().isEmpty()
                    && !redirect.contains("//")
                    && !redirect.startsWith("http")) {
                response.sendRedirect(redirect);
            } else {
                response.sendRedirect("hello-servlet");
            }

        } else {
            renderLoginPage(request, response);
        }
    }


    public void destroy() {
    }
}
