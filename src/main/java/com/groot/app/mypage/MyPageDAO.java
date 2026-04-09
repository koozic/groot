package com.groot.app.mypage;

import com.groot.app.main.DBManager_new;
import com.groot.app.product.ProductDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class MyPageDAO {
    // 싱글톤 패턴 적용
    public static final MyPageDAO MDAO = new MyPageDAO();
    private MyPageDAO() {}

    /**
     * 특정 유저가 등록한 '내 영양제' 리스트 조회
     * @param userId 세션에서 가져온 유저 ID
     * @return 유저가 등록한 ProductDTO 리스트
     */
    public ArrayList<ProductDTO> getUserProducts(String userId) {
        ArrayList<ProductDTO> myProducts = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // JOIN 쿼리: user_supplements 테이블과 products 테이블을 조인하여 해당 유저의 제품만 조회
        String sql = "SELECT p.* FROM products p " +
                "JOIN user_supplements us ON p.product_id = us.product_id " +
                "WHERE us.user_id = ?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);

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
                myProducts.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }

        return myProducts;
    }


    public boolean addMyProduct(String userId, int productId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean isSuccess = false;

        // TODO: 테이블명이 다를 경우 수정하세요 (예: user_supplements)
        String sql = "INSERT INTO user_supplements (user_id, product_id) VALUES (?, ?)";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, productId);

            // INSERT 성공 시 1 반환
            if (pstmt.executeUpdate() == 1) {
                isSuccess = true;
            }
        } catch (java.sql.SQLIntegrityConstraintViolationException e) {
            // 이미 추가된 영양제일 경우 (중복 에러 방어)
            System.out.println("이미 등록된 영양제입니다.");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }

        return isSuccess;
    }

    public boolean removeMyProduct(String userId, int productId) {
        java.sql.Connection con = null;
        java.sql.PreparedStatement pstmt = null;
        boolean isSuccess = false;

        // 매핑 테이블에서 해당 유저의 특정 제품 기록만 삭제
        String sql = "DELETE FROM user_supplements WHERE user_id = ? AND product_id = ?";

        try {
            con = com.groot.app.main.DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, productId);

            // 삭제된 행(row)이 1개 이상이면 성공 처리
            if (pstmt.executeUpdate() == 1  ) {
                isSuccess = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }

        return isSuccess;
    }
}

