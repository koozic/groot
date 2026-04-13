// 영양성분 - 관리자 모드 관련 !!

// 패키지 선언: 이 자바 파일이 어느 폴더(패키지)에 속해 있는지 선언
package com.groot.app.body;

// import 문: 필터 기능을 구현하는 데 필요한 외부 클래스들을 가져
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

// @WebFilter 어노테이션: 이 필터가 어떤 주소(URL)로 요청이 들어올 때 작동할지 설정
// 사용자가 /deleteSupplement 등의 주소로 접속하려고 하면, 해당 서블릿으로 가기 전에 무조건 이 필터를 거치게 됨
@WebFilter(urlPatterns = {"/admin", "/deleteSupplement", "/updateSupplement", "/supplements", "/supplementAdd"})

// 클래스 선언: Filter 인터페이스를 구현(implements)하는 AdminFilter 클래스 선언
public class AdminFilter implements Filter {

    @Override
    // doFilter 메서드: 사용자의 요청이 들어올 때마다 이 메서드가 실행됨.
    // req(요청 정보), res(응답 정보), chain(다음 필터나 서블릿으로 넘겨주는 객체)을 매개변수로 받음.
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        // 형변환(Casting): doFilter가 받는 기본 ServletRequest는 웹(HTTP)에 특화된 기능이 부족.
        // 그래서 더 구체적인 형태로 형변환
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // method: 사용자가 어떤 방식(GET, POST 등)으로 요청했는지 가져옴.
        // servletPath: 사용자가 요청한 핵심 주소 경로(예: /supplements)를 가져옴.
        String method = request.getMethod();
        String servletPath = request.getServletPath();

        // 💡 핵심: GET 방식이면서 주소가 '/supplements'인 경우(단순 목록 화면 조회)만 무사통과!
        // 사용자가 단순히 목록을 보려고 할 때(GET 요청이면서 주소가 /supplements인 경우)는 권한 검사를 하지 않고 통과시켜야 함.
        //이 조건에 맞으면 isReadOnly 변수에 true가 저장되고, 아니면 false가 저장
        boolean isReadOnly = "GET".equals(method) && "/supplements".equals(servletPath);

        // 단순 조회가 아니라면 (등록(POST), 수정, 삭제 등 관리자 권한이 필요한 요청이라면) 내부 로직 수행
        if (!isReadOnly) {
            // 현재 사용자의 세션 정보를 가져옴.
            // false 옵션을 주어 세션이 없으면 새로 만들지 않고 null을 반환하도록 함.
            HttpSession session = request.getSession(false);

            // 세션이 존재하면(session != null), 세션에 저장된 isAdmin 값을 꺼내옵니다.
            //세션이 없으면 null을 저장
            Boolean isAdmin = (session != null) ? (Boolean) session.getAttribute("isAdmin") : null;

            // 세션에 관리자 권한(isAdmin=true)이 없다면 접근 원천 차단
            // Boolean.TRUE = 참
            // .equals(isAdmin) => 내 기준(true)이랑 네 바구니(isAdmin)에 든 게 똑같이 생겼니?
            if (!Boolean.TRUE.equals(isAdmin)) {

                String ajaxHeader = request.getHeader("X-Requested-With");
                boolean isAjax = "XMLHttpRequest".equals(ajaxHeader) || "fetch".equals(ajaxHeader);

                if (isAjax) {
                    // 비동기 요청일 경우: 에러 코드(403)만 깔끔하게 보냅니다.
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자 권한이 필요합니다.");
                } else {
                    // 일반 요청일 경우 (예: 주소창에 직접 입력, 삭제버튼 클릭 후 이동 등): 기존 방식대로 alert 띄우기
                    // 응답 설정: 사용자 화면에 에러 메시지를 띄우기 위해 응답 형식을 HTML로 설정하고,
                    // 한글이 깨지지 않도록 UTF-8 인코딩을 적용
                    response.setContentType("text/html;charset=UTF-8");


                    // 브라우저가 실행할 자바스크립트 코드를 직접 전송
                    // 경고창(alert)을 띄우고, 확인을 누르면 영양성분 목록 페이지(/supplements)로 강제로 돌려보냄.
                    // <script> ... </script>: 브라우저에게 "이 안의 내용은 HTML이 아니라 자바스크립트니까 실행시켜!"라고 알려주는 태그
                    // request.getContextPath() : "현재 설정된 내 프로젝트 루트 폴더 주소를 알아서 찾아와서 붙여라!"
                    response.getWriter().write("<script>alert('관리자만 접근할 수 있는 기능입니다!'); location.href='" + request.getContextPath() + "/supplements';</script>");
                }
                return; // 🚨 여기서 메서드를 강제 종료하여 서블릿으로 넘어가는 것을 막음
            }
        }

        // 권한이 있거나, 단순 목록 조회라면 여기까지 도달함
        // chain.doFilter() : 문을 열어주어 사용자의 요청이 원래 가려던 다음 목적지로 통과시켜 줌.
        chain.doFilter(req, res);
    }
}