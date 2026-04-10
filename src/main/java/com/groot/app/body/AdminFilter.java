package com.groot.app.body;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

// 보호할 서블릿 주소들을 모두 매핑합니다. (등록을 담당하는 /supplements의 POST 요청도 여기서 방어합니다)
@WebFilter(urlPatterns = {"/admin", "/deleteSupplement", "/updateSupplement", "/supplements"})
public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String method = request.getMethod();
        String servletPath = request.getServletPath();

        // 💡 핵심: GET 방식이면서 주소가 '/supplements'인 경우(단순 목록 화면 조회)만 무사통과!
        boolean isReadOnly = "GET".equals(method) && "/supplements".equals(servletPath);

        // 단순 조회가 아니라면 (등록(POST), 수정, 삭제 등 관리자 권한이 필요한 요청이라면)
        if (!isReadOnly) {
            HttpSession session = request.getSession(false);
            Boolean isAdmin = (session != null) ? (Boolean) session.getAttribute("isAdmin") : null;

            // 세션에 관리자 권한(isAdmin=true)이 없다면 접근 원천 차단
            if (!Boolean.TRUE.equals(isAdmin)) {
                // 한글 깨짐 방지 세팅 후, 경고창을 띄우고 돌려보냅니다.
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write("<script>alert('관리자만 접근할 수 있는 기능입니다!'); location.href='" + request.getContextPath() + "/supplements';</script>");
                return; // 🚨 여기서 메서드를 강제 종료하여 서블릿으로 넘어가는 것을 막음
            }
        }

        // 권한이 있거나, 단순 목록 조회라면 원래 목적지(서블릿)로 통과시켜 줍니다.
        chain.doFilter(req, res);
    }
}