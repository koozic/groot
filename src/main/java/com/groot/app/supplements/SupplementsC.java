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
        // 💡 [수정된 로직] 로그인한 유저의 좋아요 목록 가져오기
        // ---------------------------------------------------------
        javax.servlet.http.HttpSession session = request.getSession(false);

        // 1) "loginUser"라는 이름으로 UserDTO 객체를 통째로 꺼냅니다.
        com.groot.app.user.UserDTO loginUser = (session != null) ? (com.groot.app.user.UserDTO) session.getAttribute("loginUser") : null;

        // 2) 객체가 있다면 그 안에서 진짜 아이디를 꺼냅니다.
        String userId = (loginUser != null) ? loginUser.getUser_id() : null;

        java.util.List<Integer> likedIds = new java.util.ArrayList<>();

        if (userId != null) {
            // 로그인한 유저라면 DAO를 실행해서 좋아요 누른 번호들을 가져옵니다.
            likedIds = SDAO.getLikedIdsByUser(userId);
        }

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
