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

    public Connection con = null;


    private ProductDAO() {
        try {
            con = DBManager_new.connect();

            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public ArrayList<ProductDTO> showAllProducts(HttpServletRequest request) {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM products";

        try {
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();
            ProductDTO dto = null;
            ArrayList<ProductDTO> products = new ArrayList<>();
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


            return products;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }

        return null;
    }
}

