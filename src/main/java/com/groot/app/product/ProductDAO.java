package com.groot.app.product;

import com.groot.app.main.DBManager_new;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
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

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void showAllProducts(HttpServletRequest request, HttpServletResponse response) {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM products";

        try {
            pstmt = PDAO.con.prepareStatement(sql);
            rs = pstmt.executeQuery();
            ProductDTO product = null;
            ArrayList<ProductDTO> products = new ArrayList<>();
            while (rs.next()) {
                int product_id = rs.getInt("product_id");
                String product_admin = rs.getString("product_admin");
                String product_name = rs.getString("product_name");
                String product_brand = rs.getString("product_brand");
                int product_price = rs.getInt("product_price");
                int product_nutrient = rs.getInt("product_nutrient");
                String product_description = rs.getString("product_description");
                String product_img = rs.getString("product_img");
                int product_total = rs.getInt("product_total");
                int product_serve = rs.getInt("product_serve");
                int product_per_day = rs.getInt("product_per_day");
                String product_time_info = rs.getString("product_time_info");
                Date product_start_date = rs.getDate("product_start_date");
                int product_current = rs.getInt("product_current");

                product = new ProductDTO(product_id, product_admin, product_name, product_brand, product_price,
                        product_nutrient, product_description, product_img, product_total, product_serve,
                        product_per_day, product_time_info, product_start_date, product_current);

                products.add(product);

            }
            request.setAttribute("products", products);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(null, pstmt, rs);
        }


    }
}
