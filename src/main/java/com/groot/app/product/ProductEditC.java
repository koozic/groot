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
            request.getRequestDispatcher("product/product_edit.jsp").forward(request, response); // 여기서 JSP로 전달함

        }

        public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
            request.setCharacterEncoding("UTF-8");

    //        ProductDAO.PDAO.productEdit(request);

            String id = ProductDAO.PDAO.productEdit(request);
            // 3. Redirect 사용하여 GET 방식으로 상세 페이지 호출
            // 이렇게 하면 ProductDetailC의 doGet이 실행되므로 405 에러가 발생하지 않습니다.
            response.sendRedirect("product-detail?id=" + id + "&update=success");

        }


        public void destroy() {
        }
    }