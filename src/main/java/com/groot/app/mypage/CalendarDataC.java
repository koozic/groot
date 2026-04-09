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
        UserDTO user = (UserDTO) request.getSession().getAttribute("loginUser");
        if (user == null) {
            response.setStatus(401);
            return;
        }

        String userId = user.getUser_id();
        int year = Integer.parseInt(request.getParameter("year"));
        int month = Integer.parseInt(request.getParameter("month"));

        // 1. 알림 데이터 호출
        ArrayList<Map<String, Object>> alertData = MyPageDAO.MDAO.getAlertData(userId);

        // 2. 당월 통계 데이터 호출 (퍼센트 -> 리스트 형식 변경 반영)
        ArrayList<Map<String, Object>> statisticsData = MyPageDAO.MDAO.getMonthlyIntakeStatistics(userId, year, month);

        // 3. 캘린더 상태 데이터 호출 (단순 체크 -> complete/partial 상태 변경 반영)
        Map<Integer, String> dailyStatus = MyPageDAO.MDAO.getMonthlyIntakeStatus(userId, year, month);

        // JSON 응답 맵 구성
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("alerts", alertData);
        responseData.put("statistics", statisticsData);
        responseData.put("dailyStatus", dailyStatus); // 키 값을 dailyStatus로 변경

        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().print(new Gson().toJson(responseData));
    }
}