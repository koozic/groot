package com.groot.app.supplements;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "DetailSupplementsC", value = "/detailSupplements")
public class DetailSupplementsC extends HttpServlet {

    // 화면 조회 (리스트 보기)
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // [비즈니스 로직] 클릭한 영양성분 '하나'만 조회하는 일 시키기
        // (아직 DAO에 이 메서드가 없다면 바로 다음에 만들 것입니다!)
        SupplementsDAO.SDAO.getSupplementDetail(request);

        // 네비게이션 탭 활성화 (영양 메뉴에 불 들어오게 하기)
        request.setAttribute("activeTab", "nutrition");

        // [어디로?] 상세 페이지 JSP를 알맹이(content)로 설정하여 index.jsp로 보냄
        request.setAttribute("content", "supplements/supplements_detail.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);

    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

    }

    public void destroy() {
    }
}
