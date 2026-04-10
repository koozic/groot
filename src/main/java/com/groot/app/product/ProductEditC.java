    package com.groot.app.product;

    import javax.servlet.ServletException;
    import javax.servlet.annotation.MultipartConfig;
    import javax.servlet.annotation.WebServlet;
    import javax.servlet.http.HttpServlet;
    import javax.servlet.http.HttpServletRequest;
    import javax.servlet.http.HttpServletResponse;
    import java.io.IOException;
    import java.util.ArrayList;

    @WebServlet(name = "ProductEditC", value = "/product-edit")
    @MultipartConfig // <--- 이게 없으면 500 에러가 터집니다!
    public class ProductEditC extends HttpServlet {

        public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
            //일
            ProductDAO.PDAO.showProductDetail(request);


            // 서블릿 doGet 내부
            ArrayList<NutrientDTO> nutrients = ProductDAO.PDAO.getAllNutrients(request);
            request.setAttribute("nutrients", nutrients); // 여기서 리스트를 "nutrients"라는 이름으로 담고

//            request.getRequestDispatcher("product/product_edit.jsp").forward(request, response); // 여기서 JSP로 전달함

            // 기존 코드 삭제
// request.getRequestDispatcher("product/product_edit.jsp").forward(request, response);

// 신규 코드 적용 (Template Pattern 포워딩)
            request.setAttribute("content", "product/product_edit.jsp");
            request.setAttribute("activeTab", "product"); // 네비게이션 하이라이트 유지
            request.getRequestDispatcher("index.jsp").forward(request, response);

        }

        public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
            request.setCharacterEncoding("UTF-8");

            // 1. Cloudinary에 이미지 업로드 후 URL 반환
            String imgUrl = com.groot.app.common.CloudinaryUtil.uploadFromRequest(request, "productImage", "products");

            // 2. 반환된 URL을 Request에 저장 (DAO로 전달하기 위함)
            if (imgUrl != null) {
                request.setAttribute("productImage", imgUrl);
            }

            String id = ProductDAO.PDAO.productEdit(request);
            // 3. Redirect 사용하여 GET 방식으로 상세 페이지 호출
            // 이렇게 하면 ProductDetailC의 doGet이 실행되므로 405 에러가 발생하지 않습니다.
            response.sendRedirect("product-detail?id=" + id + "&update=success");

        }


        public void destroy() {
        }
    }