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

    // 화면을 휙휙 넘길 때는 forward나 sendRedirect를 썼었죠? 하지만 이 서블릿은 완전히 다릅니다.
    // "화면은 그대로 두고, 뒤에서 조용히 하트 색깔만 바꿀 데이터(JSON 쪽지)만 주고받자!"

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. JSON 응답 세팅을 가장 먼저 합니다.
        // 이번엔 HTML 화면 안 줄 거야! 딱 필요한 '데이터 쪽지(JSON)'만 줄 테니까 그렇게 알아
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter(); // 일종의 펜

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
        // 자바 스크립트에 있음 => body: 'supplementId=' + supplementId
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