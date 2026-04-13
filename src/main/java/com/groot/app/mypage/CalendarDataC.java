package com.groot.app.mypage;

import com.google.gson.Gson;
import com.groot.app.mypage.MyPageDAO;
import com.groot.app.user.UserDTO;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/mypage/calData")
public class CalendarDataC extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 1. 세션 및 파라미터 확인 (Null 방어 로직 포함)
        UserDTO loginUser = (UserDTO) request.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String userId = loginUser.getUser_id();
        int year = Integer.parseInt(request.getParameter("year"));
        int month = Integer.parseInt(request.getParameter("month"));

        // 2. 모델(DAO) 호출: 계산이 모두 완료된 최종 배열만 획득
        ArrayList<Integer> checkedDates = MyPageDAO.MDAO.getCompletedIntakeDays(userId, year, month);
        ArrayList<Map<String, Object>> alerts = MyPageDAO.MDAO.getAlertData(userId);

        // 3. View(프론트엔드) 전달을 위한 데이터 패키징
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("checkedDates", checkedDates);
        responseData.put("alerts", alerts);

        // 4. JSON 직렬화 및 응답
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(new Gson().toJson(responseData));
    }
}