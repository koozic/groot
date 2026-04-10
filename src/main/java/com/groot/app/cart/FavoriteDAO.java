package com.groot.app.cart;

import com.groot.app.cart.FavoriteVO;
import com.groot.app.main.DBManager_new;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 관심제품 DAO
 * CRUD: insert(담기) / delete(빼기) / selectAll(목록) / selectOne(단건)
 * DB: Oracle / JDBC 직접 연결
 *
 * TODO: DBUtil 클래스로 Connection 관리 통일 권장
 */
public class FavoriteDAO {


    // ──────────────────────────────────────────────
    // INSERT: 장바구니 담기
    // ──────────────────────────────────────────────
    public int insert(String userId, int productId) {
        String sql = "INSERT INTO favorite_products (favorite_id, user_id, product_id) "
                + "VALUES (favorite_products_seq.NEXTVAL, ?, ?)";

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBManager_new.connect();
            ps  = con.prepareStatement(sql);
            ps.setString(1, userId);
            ps.setInt(2, productId);
            return ps.executeUpdate(); // 성공 시 1 반환

        } catch (SQLException e) {
            // 중복 담기 시 UNIQUE 제약 위반 → 0 반환
            if (e.getErrorCode() == 1) return 0;
            e.printStackTrace();
            return -1;
        } finally {
            DBManager_new.close(con, ps, null);
        }
    }

    // ──────────────────────────────────────────────
    // DELETE: 장바구니에서 빼기 (단건)
    // ──────────────────────────────────────────────
    public int delete(long favoriteId, String userId) {
        // userId도 함께 체크 → 다른 유저가 삭제 못 하게 보안 처리
        String sql = "DELETE FROM favorite_products WHERE favorite_id = ? AND user_id = ?";

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBManager_new.connect();
            ps  = con.prepareStatement(sql);
            ps.setLong(1, favoriteId);
            ps.setString(2, userId);
            return ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            DBManager_new.close(con, ps, null);
        }
    }

    // ──────────────────────────────────────────────
    // DELETE: 특정 제품 찜 해제 (favoriteId 모를 때)
    // ──────────────────────────────────────────────
    public int deleteByProduct(String userId, int productId) {
        String sql = "DELETE FROM favorite_products WHERE user_id = ? AND product_id = ?";

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBManager_new.connect();
            ps  = con.prepareStatement(sql);
            ps.setString(1, userId);
            ps.setInt(2, productId);
            return ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        } finally {
            DBManager_new.close(con, ps, null);
        }
    }

    // ──────────────────────────────────────────────
    // SELECT: 내 장바구니 전체 목록 조회 (products 테이블 JOIN)
    // ──────────────────────────────────────────────
    public List<FavoriteVO> selectAll(String userId) {
        String sql = "SELECT f.favorite_id, f.user_id, f.product_id, "
                + "       p.product_name, p.product_brand, p.product_price, p.product_image "
                + "FROM   favorite_products f "
                + "JOIN   products p ON f.product_id = p.product_id "
                + "WHERE  f.user_id = ? "
                + "ORDER  BY f.favorite_id DESC";

        List<FavoriteVO> list = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs  = null;

        try {
            con = DBManager_new.connect();
            ps  = con.prepareStatement(sql);
            ps.setString(1, userId);
            rs  = ps.executeQuery();

            while (rs.next()) {
                FavoriteVO vo = new FavoriteVO();
                vo.setFavorite_id  (rs.getInt  ("favorite_id"));
                vo.setUser_id      (rs.getString("user_id"));
                vo.setProduct_id   (rs.getInt   ("product_id"));
                vo.setProduct_name (rs.getString("product_name"));
                vo.setProduct_brand(rs.getString("product_brand"));
                vo.setProduct_price(rs.getInt   ("product_price"));
                vo.setProduct_image(rs.getString("product_image"));
                list.add(vo);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, ps, rs);
        }
        return list;
    }

    // ──────────────────────────────────────────────
    // SELECT: 이미 찜했는지 여부 확인
    // ──────────────────────────────────────────────
    public boolean isFavorite(String userId, int productId) {
        String sql = "SELECT COUNT(*) FROM favorite_products "
                + "WHERE user_id = ? AND product_id = ?";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs  = null;

        try {
            con = DBManager_new.connect();
            ps  = con.prepareStatement(sql);
            ps.setString(1, userId);
            ps.setInt(2, productId);
            rs  = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, ps, rs);
        }
        return false;
    }

    // ──────────────────────────────────────────────
    // SELECT: 장바구니 개수
    // ──────────────────────────────────────────────
    public int countByUser(String userId) {
        String sql = "SELECT COUNT(*) FROM favorite_products WHERE user_id = ?";

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs  = null;

        try {
            con = DBManager_new.connect();
            ps  = con.prepareStatement(sql);
            ps.setString(1, userId);
            rs  = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, ps, rs);
        }
        return 0;
    }
}
