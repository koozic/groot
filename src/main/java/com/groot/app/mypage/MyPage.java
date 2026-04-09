package com.groot.app.mypage;

import com.groot.app.product.ProductDAO;
import com.groot.app.product.ProductDTO;
import com.groot.app.user.UserDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "MyPage", value = "/mypage")
public class MyPage extends HttpServlet {

    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // 사물함(세션)에서 "loginUser"라는 이름표가 붙은 상자(UserDTO)를 통째로 꺼냅니다.
        UserDTO loginUser = (com.groot.app.user.UserDTO) request.getSession().getAttribute("loginUser");

        // 상자가 비어있지 않다면(로그인 상태라면), 상자를 열어서 그 안의 ID 값을 꺼냅니다.
        if (loginUser == null) {
            response.sendRedirect("user-Login"); // 이동할 로그인 주소를 맞춰주세요.
            return; // ★ 중요: 여기서 코드를 끝내버려서 밑으로 안 내려가게 막습니다.
        }
        // 여기까지 내려왔다는 것은 100% 로그인이 되어있다는 뜻! 안전하게 ID를 꺼냅니다.
        String userId = loginUser.getUser_id();

        // 전체 리스트 확인용
        ProductDAO.PDAO.showAllProducts(request);
        // nutrients 리스트가 request에 담겨있어야 JSP의 c:forEach가 작동합니다.
        request.setAttribute("nutrients", ProductDAO.PDAO.getAllNutrients(request));

        // 화면에 띄울 '내 영양제' (MyPageDAO에 새로 만들어야 함)
        ArrayList<ProductDTO> myProducts = MyPageDAO.MDAO.getUserProducts(userId);
        ArrayList<Integer> intakeList = MyPageDAO.MDAO.getTodayIntakeList(userId);


        request.setAttribute("myProducts", myProducts);
        request.setAttribute("intakeList", intakeList); // JSP에서 체크 여부 판단용
        // HomeServlet.java 예시
        request.setAttribute("content", "mypage/mypage.jsp");
        request.setAttribute("activeTab", "home");
        request.getRequestDispatcher("index.jsp").forward(request, response);

    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {


        request.setAttribute("content", "mypage/mypage.jsp");
        request.setAttribute("activeTab", "home");
        request.getRequestDispatcher("index.jsp").forward(request, response);

    }

    public void destroy() {
    }
}