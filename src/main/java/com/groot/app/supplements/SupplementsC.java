package com.groot.app.supplements;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
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

        // 1. 사용자가 요청한 페이지 번호 받기 (기본값은 1페이지)
        int p = 1;
        String pParam = request.getParameter("p");
        if (pParam != null) {
            p = Integer.parseInt(pParam); // ?p=2 처럼 숫자가 넘어오면 그 숫자로 변경
        }

        // 2. DAO에게 전체 리스트 가져오라고 시키기
        List<SupplementsDTO> allList = SDAO.getSupplementsList();

        // 3. 가져온 전체 리스트를 페이징 메서드에 넘겨서 자르기!
        SDAO.paging(p, request, allList);

        // 4. 화면 포워딩 (기존 코드와 동일)
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
