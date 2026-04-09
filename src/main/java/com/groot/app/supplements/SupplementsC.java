package com.groot.app.supplements;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

import static com.groot.app.supplements.SupplementsDAO.SDAO;

@WebServlet(name = "SupplementsC", value = "/supplements")

public class SupplementsC extends HttpServlet {

    // 화면 조회 (리스트 보기)
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // 1. 페이지 번호 처리 (기본 코드)
        int p = 1;
        String pParam = request.getParameter("p");
        if (pParam != null) {
            p = Integer.parseInt(pParam);
        }

        // 2. 전체 영양제 리스트 가져오기 (기본 코드)
        List<SupplementsDTO> allList = SDAO.getSupplementsList();

        // ---------------------------------------------------------
        // [새로 추가할 로직] 로그인한 유저의 좋아요 목록 가져오기
        // ---------------------------------------------------------
        // 세션에서 로그인 정보를 가져옵니다.
        javax.servlet.http.HttpSession session = request.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;

        // 결과를 담을 리스트 (로그인 안 했을 경우를 대비해 미리 생성)
        java.util.List<Integer> likedIds = new java.util.ArrayList<>();

        // 로그인 상태라면 DB에서 좋아요한 ID 목록을 조회해옵니다.
        if (userId != null) {
            likedIds = SDAO.getLikedIdsByUser(userId);
        }

        // JSP에서 사용할 수 있도록 request에 담아줍니다.
        request.setAttribute("likedIds", likedIds);
        // ---------------------------------------------------------

        // 3. 페이징 처리 및 화면 포워딩
        SDAO.paging(p, request, allList);

        request.setAttribute("activeTab", "nutrition");
        request.setAttribute("content", "supplements/supplements.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }


    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // DAO의 등록 메서드 실행
        SDAO.addSupplement(request);

        // 등록이 끝나면 다시 리스트 화면(doGet)으로 새로고침
        response.sendRedirect("supplements");
    }

    public void destroy() { }

}
