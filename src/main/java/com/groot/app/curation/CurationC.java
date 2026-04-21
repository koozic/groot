package com.groot.app.curation;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "CurationC", value = {"/curation", "/curation_view"})
public class CurationC extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        request.setAttribute("activeTab", "recommend");
        request.setAttribute("content", "curation/curation.jsp");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    public void destroy() {
    }
}