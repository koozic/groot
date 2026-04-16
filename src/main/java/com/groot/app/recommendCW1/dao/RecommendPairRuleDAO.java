package com.groot.app.recommendCW1.dao;

import com.groot.app.main.DBManager_new;
import com.groot.app.recommendCW1.dto.RecommendPairRuleDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class RecommendPairRuleDAO {
    public static final RecommendPairRuleDAO DAO = new RecommendPairRuleDAO();

    private RecommendPairRuleDAO() {
    }

    public List<RecommendPairRuleDTO> getGoodPairRules() {
        String sql = "SELECT gp.good_pair_id, gp.supplement_id_1, s1.supplement_name AS supplement_name_1, " +
                "       gp.supplement_id_2, s2.supplement_name AS supplement_name_2, gp.reason " +
                "FROM supplement_good_pair gp " +
                "JOIN supplements s1 ON gp.supplement_id_1 = s1.supplement_id " +
                "JOIN supplements s2 ON gp.supplement_id_2 = s2.supplement_id " +
                "ORDER BY gp.good_pair_id";
        return getPairRules(sql, true);
    }

    public List<RecommendPairRuleDTO> getBadPairRules() {
        String sql = "SELECT bp.bad_pair_id, bp.supplement_id_1, s1.supplement_name AS supplement_name_1, " +
                "       bp.supplement_id_2, s2.supplement_name AS supplement_name_2, bp.reason, bp.interval_hours " +
                "FROM supplement_bad_pair bp " +
                "JOIN supplements s1 ON bp.supplement_id_1 = s1.supplement_id " +
                "JOIN supplements s2 ON bp.supplement_id_2 = s2.supplement_id " +
                "ORDER BY bp.bad_pair_id";
        return getPairRules(sql, false);
    }

    private List<RecommendPairRuleDTO> getPairRules(String sql, boolean goodPair) {
        List<RecommendPairRuleDTO> list = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                RecommendPairRuleDTO dto = new RecommendPairRuleDTO();
                dto.setRuleId(rs.getInt(1));
                dto.setSupplementId1(rs.getInt("supplement_id_1"));
                dto.setSupplementName1(rs.getString("supplement_name_1"));
                dto.setSupplementId2(rs.getInt("supplement_id_2"));
                dto.setSupplementName2(rs.getString("supplement_name_2"));
                dto.setReason(rs.getString("reason"));
                dto.setIntervalHours(goodPair ? null : rs.getInt("interval_hours"));
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
