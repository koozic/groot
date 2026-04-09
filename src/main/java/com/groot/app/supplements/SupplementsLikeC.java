package com.groot.app.supplements;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

public class SupplementsLikeC {

    @WebServlet("/supplementsLike")
    public class LikeServlet extends HttpServlet {

        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {

            response.setContentType("application/json;charset=UTF-8");
            // 브라우저에게 텍스트를 출력(전송)하기 위한 펜(도구)을 준비
            PrintWriter out = response.getWriter();

            HttpSession session = request.getSession(false);
            // 괄호 안의 true / false가 뜻하는 질문이"세션이 없을 때 새로 만들어줄까(Create)?"임.
            // request.getSession(true) (또는 괄호 생략): "기존 세션이 있으면 그거 주고, 없으면 새로 만들어줘(true)."
            // request.getSession(false): "기존 세션이 있으면 그거 주고, 없으면 절대 새로 만들지 말고 그냥 null을 뱉어(false)."

            // 로그인 체크
            if (session == null || session.getAttribute("userId") == null) {
                out.print("{\"status\":\"error\",\"message\":\"로그인이 필요합니다.\"}");
                // 이스케이프(Escape) 문자
                // 자바가 쌍따옴표를 '문자열의 끝'으로 오해하지 않도록 알려주는 기호가 바로 \

                // 현재 실행 중인 메서드(doPost)만 즉시 종료(아래 코드는 실행 안 함)
                return;
            }
            // 검증을 무사히 통과했다면, 세션에서 드디어 유저 아이디를 꺼내어 변수에 저장
            String userId = (String) session.getAttribute("userId");

            // 브라우저가 보낸 요청 안에서 supplementId라는 이름으로 넘어온 값을 찾습니다.
            // (이 값은 항상 문자열(String)로 넘어옵니다.)
            String idParam = request.getParameter("supplementId");

            if (idParam == null) {
                out.print("{\"status\":\"error\",\"message\":\"잘못된 요청입니다.\"}");
                return;
            }

            int supplementId = Integer.parseInt(idParam);
            // 프론트엔드(웹 브라우저)에서 백엔드(자바)로 데이터를 보낼 때 사용하는 통신 규칙(HTTP)은 모든 데이터를 '문자열(String)'로 취급한다.
            // DB는 공간 자체를 숫자 타입(INT/NUMBER)으로 제한함
            // 그래서 숫자 형태로 바꿔주어야 함.

            String result = SupplementsDAO.SDAO.supplementLike(userId, supplementId);

            // "liked" 또는 "unliked" 반환
            out.print("{\"status\":\"" + result + "\"}");
            // 최종 결과를 다시 JSON 형태({"status":"liked"})로 조립하여 브라우저로 전송
            // "왜 요즘 웹 개발에서는 데이터를 주고받을 때 다른 형태가 아닌 JSON을 가장 많이 쓸까요?"
            // 1. 자바스크립트(JavaScript)와의 완벽한 찰떡궁합
            // 2. 화면을 새로고침 하지 않기 위해서 (SPA & 비동기 통신)
            // 과거에는 버튼을 누르면 서버가 아예 새로운 HTML 페이지 전체를 만들어서 브라우저로 보냈습니다.
            // (이러면 화면이 번쩍! 하면서 새로고침 됩니다.)
            // 하지만 요즘 웹페이지(유튜브, 인스타그램 등)는 좋아요를 눌러도
            // 화면 전체가 새로고침되지 않고 하트만 빨갛게 변합니다. 이를 비동기 통신(AJAX/Fetch)이라고 합니다.
            // 화면(HTML)은 그대로 두고, 순수하게 필요한 '데이터(결과값)'만 뒷단에서 몰래 받아와서
            // 하트만 색칠하는 것입니다. 이렇게 순수 데이터만 주고받는 데 가장 최적화된 포맷이 바로 JSON입니다.
        }
    }
        }

