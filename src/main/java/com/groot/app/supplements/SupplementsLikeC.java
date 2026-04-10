package com.groot.app.supplements;

import com.groot.app.user.UserDTO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/supplementsLike")
public class SupplementsLikeC extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. JSON 응답 세팅을 가장 먼저 합니다.
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 2. 세션에서 로그인 유저 정보 꺼내기
        HttpSession session = request.getSession(false);
        UserDTO loginUser = (session != null) ? (UserDTO) session.getAttribute("loginUser") : null;

        // 3. 로그인 체크 (안 되어있으면 에러 반환하고 종료)
        if (loginUser == null) {
            out.print("{\"status\":\"error\", \"message\":\"로그인이 필요합니다.\"}");
            return;
        }

        // 4. 유저 ID 추출
        String userId = loginUser.getUser_id();

        // 5. 프론트에서 보낸 영양제 번호 받기
        String idParam = request.getParameter("supplementId");

        if (idParam == null || idParam.trim().isEmpty()) {
            out.print("{\"status\":\"error\", \"message\":\"잘못된 요청입니다.\"}");
            return;
        }

        try {
            int supplementId = Integer.parseInt(idParam);

            // 6. DAO 실행 (반환값은 반드시 "liked" 또는 "unliked" 여야 합니다!)
            // 🚨 경고: SDAO.supplementLike 메서드가 반환하는 값이 String("liked", "unliked")이어야 아래 코드가 성립합니다.
            String result = SupplementsDAO.SDAO.supplementLike(userId, supplementId);

            // 7. 결과 반환 (JS가 기대하는 형태)
            out.print("{\"status\":\"" + result + "\"}");

        } catch (NumberFormatException e) {
            out.print("{\"status\":\"error\", \"message\":\"숫자 형식이 아닙니다.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\", \"message\":\"서버 오류가 발생했습니다.\"}");
        }
    }
}