package com.groot.app.body;

import com.groot.app.main.DBManager_new;

import java.sql.*;

public class AdminLoginDAO {

    // admin 로그인 검증
    public AdminDTO login(String adminId, String adminPw) throws Exception {
        String sql = "SELECT admin_no, admin_id, admin_name, admin_email " +
                "FROM admin " +
                "WHERE admin_id = ? AND admin_pw = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, adminId);
            ps.setString(2, adminPw);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    AdminDTO dto = new AdminDTO();
                    dto.setAdminNo(rs.getInt("admin_no"));
                    dto.setAdminId(rs.getString("admin_id"));
                    dto.setAdminName(rs.getString("admin_name"));
                    dto.setAdminEmail(rs.getString("admin_email"));
                    return dto; // 로그인 성공
                }
            }
        }
        return null; // 로그인 실패
    }
}