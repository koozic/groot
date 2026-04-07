package com.groot.app.product;

import com.groot.app.main.DBManager_new;

import javax.servlet.http.HttpServletRequest;
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

    public void productDelete(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = "delete from products where product_id = ?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(request.getParameter("id")));

            if (pstmt.executeUpdate() == 1) {
                System.out.println("delete success");
            }


        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }


    }

    public String productEdit(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String id = request.getParameter("productId");
        String sql = "update products set product_name = ?, product_brand = ?, product_price = ?, " +
                "product_nutrient = ?, product_description = ?, product_image = ?, product_total = ?," +
                "product_serve = ?, product_per_day = ?, product_time_info = ? where product_id = ?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(11, Integer.parseInt(request.getParameter("productId")));
            pstmt.setString(1, request.getParameter("productName"));
            pstmt.setString(2, request.getParameter("productBrand"));
            pstmt.setInt(3, Integer.parseInt(request.getParameter("productPrice")));
            pstmt.setInt(4, Integer.parseInt(request.getParameter("productNutrient")));
            pstmt.setString(5, request.getParameter("productDescription"));
            pstmt.setString(6, request.getParameter("productImage"));
            pstmt.setInt(7, Integer.parseInt(request.getParameter("productTotal")));
            pstmt.setInt(8, Integer.parseInt(request.getParameter("productServe")));
            pstmt.setInt(9, Integer.parseInt(request.getParameter("productPerDay")));
            pstmt.setString(10, request.getParameter("productTimeInfo"));




            if (pstmt.executeUpdate() == 1) {
                System.out.println("update success");
            }


        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }
        return id;


    }
}

