package com.groot.app.product;

import com.groot.app.common.CloudinaryUtil;
import com.groot.app.main.DBManager_new;
import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.Part;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Date;

public class ProductDAO {
    public static final ProductDAO PDAO = new ProductDAO();

//    public Connection con = null;


    private ProductDAO() {
//        try {
//            con = DBManager_new.connect();
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
    }

    public void showAllProducts(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM products";

        ProductDTO dto = null;
        ArrayList<ProductDTO> products = new ArrayList<>();
        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                dto = new ProductDTO(
                        rs.getInt("product_id"),
                        rs.getString("product_admin"),
                        rs.getString("product_name"),
                        rs.getString("product_brand"),
                        rs.getInt("product_price"),
                        rs.getInt("product_nutrient"),
                        rs.getString("product_description"),
                        rs.getString("product_image"),
                        rs.getInt("product_total"),
                        rs.getInt("product_serve"),
                        rs.getInt("product_per_day"),
                        rs.getString("product_time_info"),
                        rs.getDate("product_start_date"),
                        rs.getInt("product_current"));

                products.add(dto);
            }

            request.setAttribute("products", products);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }

    }

    /**
     * 2. 페이징 처리가 포함된 실제 로직 메서드
     */
    public void showAllProducts(HttpServletRequest request, int page) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // Oracle ROWNUM 페이징 쿼리 및 올바른 테이블명(products) 적용
        String sql = "SELECT * FROM ("
                + "    SELECT ROWNUM AS rnum, a.* FROM ("
                + "        SELECT * FROM products ORDER BY product_id DESC"
                + "    ) a WHERE ROWNUM <= ?"
                + ") WHERE rnum > ?";

        int limit = 9;
        int endRow = page * limit;
        int startRow = (page - 1) * limit;

        ArrayList<ProductDTO> products = new ArrayList<>();

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);

            // [수정] limit -> endRow 로 변경
            pstmt.setInt(1, endRow);
            pstmt.setInt(2, startRow);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                ProductDTO dto = new ProductDTO(
                        rs.getInt("product_id"),
                        rs.getString("product_admin"),
                        rs.getString("product_name"),
                        rs.getString("product_brand"),
                        rs.getInt("product_price"),
                        rs.getInt("product_nutrient"),
                        rs.getString("product_description"),
                        rs.getString("product_image"),
                        rs.getInt("product_total"),
                        rs.getInt("product_serve"),
                        rs.getInt("product_per_day"),
                        rs.getString("product_time_info"),
                        rs.getDate("product_start_date"),
                        rs.getInt("product_current")
                );
                products.add(dto);
            }

            // 결과를 request 영역에 저장
            request.setAttribute("products", products);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
    }

    public void showProductsByNutrient(HttpServletRequest request, String nutrientId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM products WHERE product_nutrient = ?";

        ProductDTO dto = null;
        ArrayList<ProductDTO> products = new ArrayList<>();
        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(nutrientId)); // 파라미터 바인딩
            rs = pstmt.executeQuery();

            while (rs.next()) {
                dto = new ProductDTO(
                        rs.getInt("product_id"),
                        rs.getString("product_admin"),
                        rs.getString("product_name"),
                        rs.getString("product_brand"),
                        rs.getInt("product_price"),
                        rs.getInt("product_nutrient"),
                        rs.getString("product_description"),
                        rs.getString("product_image"),
                        rs.getInt("product_total"),
                        rs.getInt("product_serve"),
                        rs.getInt("product_per_day"),
                        rs.getString("product_time_info"),
                        rs.getDate("product_start_date"),
                        rs.getInt("product_current"));

                products.add(dto);
            }

            request.setAttribute("products", products);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
    }

    public void showProductsByNutrient(HttpServletRequest request, String nutrientId, int page) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // Oracle ROWNUM 페이징 + 카테고리 필터 조건 결합
        String sql = "SELECT * FROM ("
                + "    SELECT ROWNUM AS rnum, a.* FROM ("
                + "        SELECT * FROM products WHERE product_nutrient = ? ORDER BY product_id DESC"
                + "    ) a WHERE ROWNUM <= ?"
                + ") WHERE rnum > ?";

        int limit = 9;
        int endRow = page * limit;
        int startRow = (page - 1) * limit;

        ArrayList<ProductDTO> products = new ArrayList<>();

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);

            // [수정] 파라미터 인덱스 주의 및 limit -> endRow 로 변경
            pstmt.setString(1, nutrientId);
            pstmt.setInt(2, endRow);
            pstmt.setInt(3, startRow);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                ProductDTO dto = new ProductDTO(
                        rs.getInt("product_id"),
                        rs.getString("product_admin"),
                        rs.getString("product_name"),
                        rs.getString("product_brand"),
                        rs.getInt("product_price"),
                        rs.getInt("product_nutrient"),
                        rs.getString("product_description"),
                        rs.getString("product_image"),
                        rs.getInt("product_total"),
                        rs.getInt("product_serve"),
                        rs.getInt("product_per_day"),
                        rs.getString("product_time_info"),
                        rs.getDate("product_start_date"),
                        rs.getInt("product_current")
                );
                products.add(dto);
            }

            request.setAttribute("products", products);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
    }

    public void showProductDetail(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM products where product_id = ?";

        ProductDTO dto = null;
        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, request.getParameter("id"));
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = new ProductDTO(
                        rs.getInt("product_id"),
                        rs.getString("product_admin"),
                        rs.getString("product_name"),
                        rs.getString("product_brand"),
                        rs.getInt("product_price"),
                        rs.getInt("product_nutrient"),
                        rs.getString("product_description"),
                        rs.getString("product_image"),
                        rs.getInt("product_total"),
                        rs.getInt("product_serve"),
                        rs.getInt("product_per_day"),
                        rs.getString("product_time_info"),
                        rs.getDate("product_start_date"),
                        rs.getInt("product_current"));

            }
            request.setCharacterEncoding("UTF-8");
            request.setAttribute("product", dto);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }


    }

    public void getNutrientInfo(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // 제품 정보에서 가져온 product_nutrient ID 사용
        ProductDTO pDto = (ProductDTO) request.getAttribute("product");
        if (pDto == null) return;

        String sql = "SELECT * FROM supplements WHERE supplement_id = ?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, pDto.getProductNutrient());
            rs = pstmt.executeQuery();

            if (rs.next()) {
                NutrientDTO nutrientData = new NutrientDTO(
                        rs.getInt("supplement_id"),
                        rs.getString("supplement_name")
                );
                // 별도의 attribute로 저장
                request.setAttribute("nutrient", nutrientData);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
    }

    public void productDelete(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = "delete from products where product_id = ?";
        int productId = Integer.parseInt(request.getParameter("id"));
        String oldImage = getProductImageById(productId);

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, productId);

            if (pstmt.executeUpdate() == 1) {
                System.out.println("delete success");
                CloudinaryUtil.deleteFileByUrl(oldImage);
            }


        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }


    }

    public String productEdit(HttpServletRequest request) throws IOException {
        Connection con = null;
        PreparedStatement pstmt = null;
        String id = request.getParameter("productId");
        String sql = "update products set product_name = ?, product_brand = ?, product_price = ?, " +
                "product_nutrient = ?, product_description = ?, product_image = ?, product_total = ?," +
                "product_serve = ?, product_per_day = ?, product_time_info = ? where product_id = ?";
        String newProductImage = (String) request.getAttribute("productImage");
        boolean hasNewUpload = newProductImage != null && !newProductImage.isBlank();
        String oldImage = null;


        try {
            int productId = Integer.parseInt(id);
            oldImage = getProductImageById(productId);
            if (oldImage == null || oldImage.isBlank()) {
                oldImage = request.getParameter("oldProductImage");
            }
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(11, productId);
            pstmt.setString(1, request.getParameter("productName"));
            pstmt.setString(2, request.getParameter("productBrand"));
            pstmt.setInt(3, Integer.parseInt(request.getParameter("productPrice")));
            pstmt.setInt(4, Integer.parseInt(request.getParameter("productNutrient")));
            pstmt.setString(5, request.getParameter("productDescription"));


            String finalProductPath = newProductImage;
            if (!hasNewUpload) {
                finalProductPath = oldImage;
            }
            if (finalProductPath == null) {
                finalProductPath = "";
            }


            pstmt.setString(6, finalProductPath);


            pstmt.setInt(7, Integer.parseInt(request.getParameter("productTotal")));
            pstmt.setInt(8, Integer.parseInt(request.getParameter("productServe")));
            pstmt.setInt(9, Integer.parseInt(request.getParameter("productPerDay")));
            pstmt.setString(10, request.getParameter("productTimeInfo"));


            if (pstmt.executeUpdate() == 1) {
                System.out.println("update success");
                if (hasNewUpload && oldImage != null && !oldImage.equals(newProductImage)) {
                    CloudinaryUtil.deleteFileByUrl(oldImage);
                }
            } else if (hasNewUpload) {
                CloudinaryUtil.deleteFileByUrl(newProductImage);
            }


        } catch (Exception e) {
            if (hasNewUpload) {
                CloudinaryUtil.deleteFileByUrl(newProductImage);
            }
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }
        return id;

    }

    private String getProductImageById(int productId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "select product_image from products where product_id = ?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getString("product_image");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return null;
    }

    public ArrayList<NutrientDTO> getAllNutrients(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList<NutrientDTO> list = new ArrayList<>();
        String sql = "SELECT supplement_id, supplement_name FROM supplements"; // 실제 테이블명에 맞게 수정

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                // ID와 이름을 담은 DTO 객체 생성 (SupplementsDTO가 별도로 있어야 함)
                list.add(new NutrientDTO(rs.getInt("supplement_id"),
                        rs.getString("supplement_name")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return list;
    }

    public void productAdd(HttpServletRequest request) throws IOException {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO products VALUES (products_seq.nextval,?,?,?,?,?,?,?,?,?,?,?,?,?)";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);

            //?체우기
            pstmt.setString(1, request.getParameter("productAdmin"));
            pstmt.setString(2, request.getParameter("productName"));
            pstmt.setString(3, request.getParameter("productBrand"));
            pstmt.setInt(4, Integer.parseInt(request.getParameter("productPrice")));
            pstmt.setInt(5, Integer.parseInt(request.getParameter("productNutrient")));
            pstmt.setString(6, request.getParameter("productDescription"));


            String finalProductPath = (String) request.getAttribute("productImage");

            // 이미지가 업로드되지 않아 null일 경우, 빈 문자열 처리 (DB 제약조건에 따라 선택적 적용)
            if (finalProductPath == null) {
                finalProductPath = "";
            }


            pstmt.setString(7, finalProductPath);
            pstmt.setInt(8, Integer.parseInt(request.getParameter("productTotal")));
            pstmt.setInt(9, Integer.parseInt(request.getParameter("productServe")));
            pstmt.setInt(10, Integer.parseInt(request.getParameter("productPerDay")));
            pstmt.setString(11, request.getParameter("productTimeInfo"));
            pstmt.setDate(12, new java.sql.Date(new java.util.Date().getTime()));
            pstmt.setInt(13, 0);


            if (pstmt.executeUpdate() == 1) {
                System.out.println("insert success");
            }


        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }


    }
}

