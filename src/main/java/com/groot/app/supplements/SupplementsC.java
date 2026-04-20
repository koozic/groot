package com.groot.app.supplements;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;
import java.util.List;

import static com.groot.app.supplements.SupplementsDAO.SDAO;

@WebServlet(name = "SupplementsC", value = "/supplements")

// 파일 업로드를 위해 반드시 추가해야 하는 설정
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 5,       // 5MB
        maxRequestSize = 1024 * 1024 * 10    // 10MB
)

public class SupplementsC extends HttpServlet {

    // 화면 조회 (리스트 보기)
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        // ---------------------------------------------------------
        // 페이지 번호 처리 (기본 코드)
        // ---------------------------------------------------------
        int p = 1;
        String pParam = request.getParameter("p"); // 출처 : JSP 화면의 페이징 버튼
        if (pParam != null) {
            // "글자(String)"로 된 숫자를 진짜 "숫자(int)"로 번역
            p = Integer.parseInt(pParam);
        }



        // 전체 영양제 리스트 가져오기 - 일 시키기
        List<SupplementsDTO> allList = SDAO.getSupplementsList();



        // ---------------------------------------------------------
        // 로그인한 유저의 좋아요 목록 가져오기
            // 현재 접속한 사람이 누구인지 확인하고, 그 사람이 과거에 '좋아요(하트)'를 눌렀던 영양제 번호들을 싹 다 긁어와서 화면(JSP)에 넘겨주는 역할
            // 이 로직이 없으면 모든 사용자의 화면에 하트가 텅 빈 상태로 나오게 됨
        // ---------------------------------------------------------

        // 세션(Session) 확인하기
        javax.servlet.http.HttpSession session = request.getSession(false);

        // 사물함에서 유저 정보 꺼내기 (삼항 연산자)
        com.groot.app.user.UserDTO loginUser = (session != null) ? (com.groot.app.user.UserDTO) session.getAttribute("loginUser") : null;

        // 진짜 '아이디(ID)'만 쏙 뽑아내기
        String userId = (loginUser != null) ? loginUser.getUser_id() : null;

        // '좋아요' 번호를 담을 텅 빈 바구니 준비
        java.util.List<Integer> likedIds = new java.util.ArrayList<>();

        // 로그인한 유저라면? DB에서 데이터 긁어오기
        if (userId != null) {
            // 로그인한 유저라면 DAO를 실행해서 좋아요 누른 번호들을 가져옵니다.
            likedIds = SDAO.getLikedIdsByUser(userId);
        }

        // 완성된 바구니를 화면(JSP)으로 배달하기
        request.setAttribute("likedIds", likedIds);
        // ---------------------------------------------------------



        // 3. 페이징 처리 및 화면 포워딩
        SDAO.paging(p, request, allList);

        request.setAttribute("activeTab", "nutrition");

        request.setAttribute("content", "supplements/supplements.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }


    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // 1. 한글 깨짐 방지
        request.setCharacterEncoding("UTF-8");

        // 2. 모달 폼에서 전송한 사진 파일(supplementFile) 꺼내기
        Part filePart = request.getPart("supplementFile");

        // 3. Cloudinary를 사용해 업로드하고, 완성된 이미지 링크(URL) 받아오기
        String imageUrl = null;
        if (filePart != null && filePart.getSize() > 0) {
            imageUrl = com.groot.app.common.CloudinaryUtil.uploadFile(filePart, "supplements");
        } else {
            // 사용자가 사진을 첨부하지 않았을 때: 기본 이미지 주소 넣기
            imageUrl = "default.png";
        }

        // 4. 받아온 링크를 주방(DAO)에 전달하기 위해 request 상자에 담기
        if (imageUrl != null) {
            request.setAttribute("newImageUrl", imageUrl);
        }

        // 5. DAO의 등록 메서드 실행 (DB 저장)
        SDAO.addSupplement(request);

        // 6. 등록이 끝나면 다시 리스트 화면(doGet)으로 새로고침
        response.sendRedirect("supplements");
    }


    public void destroy() { }

}
