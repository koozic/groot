package com.groot.app.recommendCW1.dao;

import com.groot.app.main.DBManager_new;
import com.groot.app.recommendCW1.dto.RecommendSupplementDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class RecommendSupplementDAO {
    public static final RecommendSupplementDAO DAO = new RecommendSupplementDAO();

    private RecommendSupplementDAO() {
    }

    public List<RecommendSupplementDTO> getAllSupplements() {
        List<RecommendSupplementDTO> list = new ArrayList<>();
        String sql = "SELECT supplement_id, supplement_name, supplement_timing, supplement_caution, " +
                "       supplement_image_path, supplement_view_count " +
                "FROM supplements " +
                "ORDER BY supplement_view_count DESC, supplement_name ASC";

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                RecommendSupplementDTO dto = new RecommendSupplementDTO();
                dto.setSupplementId(rs.getInt("supplement_id"));
                dto.setSupplementName(rs.getString("supplement_name"));
                dto.setSupplementTiming(rs.getString("supplement_timing"));
                dto.setSupplementCaution(rs.getString("supplement_caution"));
                dto.setSupplementImagePath(rs.getString("supplement_image_path"));
                dto.setSupplementViewCount(rs.getInt("supplement_view_count"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }

        return list;
    }
}
