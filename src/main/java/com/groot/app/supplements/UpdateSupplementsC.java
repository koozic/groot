package com.groot.app.supplements;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "UpdateSupplementsC", value = "/updateSupplement")
@MultipartConfig(
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10

)
public class UpdateSupplementsC extends HttpServlet {

    // 화면 조회 (리스트 보기)
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        // DAO에 있는 상세 조회 메서드(기존 데이터를 하나 불러오는 기능)를 그대로 재사용
        SupplementsDAO.SDAO.getSupplementDetail(request);

        // 수정용 JSP 페이지로 포워딩
        request.setAttribute("content", "supplements/supplements_update.jsp");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

    //이찬우 이미지 테스용======================

        // 2. JSP의 <input type="file" name="supplementFile"> 에서 파일을 꺼냅니다.
        // (JSP의 input name이 "supplementFile"라고 가정했습니다. 다르면 수정하세요!)
        Part filePart = request.getPart("supplementFile");

        // 3. CloudinaryUtil을 사용하여 업로드 후 URL 받기
        // 파일이 선택되지 않았을 수도 있으니 유틸리티에서 처리한 값을 받습니다.
        String imageUrl = com.groot.app.common.CloudinaryUtil.uploadFile(filePart, "supplements");

        // 4. 업로드된 URL을 DAO가 알 수 있도록 request에 담아줍니다.
        // 이렇게 담아두면 DAO에서 request.getAttribute("newImageUrl")로 꺼낼 수 있습니다.
        if (imageUrl != null) {
            request.setAttribute("newImageUrl", imageUrl);
        }

        // 5. 이제 DAO 실행 (이 안에서 DB 업데이트를 처리하겠죠?)
        SupplementsDAO.SDAO.updateSupplement(request);

        // 6. 완료 후 리스트로 이동
        response.sendRedirect("supplements");


    //===================================================
    }

    public void destroy() {
    }
}
