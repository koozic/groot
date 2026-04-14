package com.groot.app.mypage;

import com.groot.app.product.ProductDAO;
import com.groot.app.product.ProductDTO;
import com.groot.app.user.UserDTO;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Map;

@WebServlet(name = "MyPage", value = "/mypage")
public class MyPage extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        UserDTO loginUser = (UserDTO) request.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("user-Login");
            return;
        }
        String userId = loginUser.getUser_id();

        // ── AJAX 정렬 요청은 가장 먼저 처리하고 return ──
        String action = request.getParameter("action");
        if ("myLikes".equals(action)) {
            response.setContentType("application/json; charset=UTF-8");
            String sort = request.getParameter("sort");
            if (sort == null) sort = "recent";

            ArrayList<com.groot.app.supplements.SupplementsDTO> list =
                    MyPageDAO.MDAO.getLikedSupplements(userId, sort);
            response.getWriter().print(new Gson().toJson(list));
            return; // ← 여기서 끝, 아래 페이지 렌더링 안 함
        }

        // ── 일반 페이지 렌더링 ──
        ProductDAO.PDAO.showAllProducts(request);
        request.setAttribute("nutrients", ProductDAO.PDAO.getAllNutrients(request));

        ArrayList<ProductDTO> myProducts = MyPageDAO.MDAO.getUserProducts(userId);
        ArrayList<Integer> intakeList = MyPageDAO.MDAO.getTodayIntakeList(userId);

        LocalDate now = LocalDate.now();
        int currentYear = now.getYear();
        int currentMonth = now.getMonthValue();

        ArrayList<Map<String, Object>> monthlyStats =
                MyPageDAO.MDAO.getMonthlyIntakeStatistics(userId, currentYear, currentMonth);

        ArrayList<com.groot.app.supplements.SupplementsDTO> likedSupplements =
                MyPageDAO.MDAO.getLikedSupplements(userId, "recent");

        request.setAttribute("myProducts", myProducts);
        request.setAttribute("intakeList", intakeList);
        request.setAttribute("monthlyStats", monthlyStats);
        request.setAttribute("likedSupplements", likedSupplements);
        request.setAttribute("content", "mypage/mypage.jsp");
        request.setAttribute("activeTab", "home");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("content", "mypage/mypage.jsp");
        request.setAttribute("activeTab", "home");
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}