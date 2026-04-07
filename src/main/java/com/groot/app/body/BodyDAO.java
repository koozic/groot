package com.groot.app.body;

import com.groot.app.main.DBManager_new;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BodyDAO {

    // ─────────────────────────────────────────
    // 1. 모든 신체 부위 목록 조회
    // ─────────────────────────────────────────
    public List<BodyDTO> getAllBodies() throws Exception {
        List<BodyDTO> list = new ArrayList<>();

        // ✅ 실제 DB 컬럼명 그대로 사용
        String sql = "SELECT body_id, body_name, body_image " +
                "FROM body " +
                "ORDER BY body_id";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                BodyDTO dto = new BodyDTO();
                dto.setBodyId(rs.getInt("body_id"));
                dto.setBodyName(rs.getString("body_name"));
                dto.setBodyImage(rs.getString("body_image"));
                list.add(dto);
            }
        }
        return list;
    }

    // ─────────────────────────────────────────
    // 2. 특정 신체 부위의 영양소 목록 조회
    //    sortType: "view"=조회순 / "like"=좋아요순 / 기본=최신(reg_date)순
    // ─────────────────────────────────────────
    public List<BodyDTO> getSupplementsByBody(int bodyId, String sortType) throws Exception {
        List<BodyDTO> list = new ArrayList<>();

        String orderBy;
        if ("like".equals(sortType)) {
            orderBy = "like_cnt DESC, s.supplement_view_count DESC";
        } else if ("view".equals(sortType)) {
            orderBy = "s.supplement_view_count DESC, like_cnt DESC";
        } else {
            // ✅ 기본값: supplement_reg_date 최신순 (실제 DB 컬럼 반영)
            orderBy = "s.supplement_reg_date DESC";
        }

        String sql = "SELECT s.supplement_id, " +
                "       s.supplement_name, " +
                "       s.supplement_efficacy, " +
                "       s.supplement_dosage, " +
                "       s.supplement_timing, " +
                "       s.supplement_caution, " +
                "       s.supplement_image_path, " +
                "       s.supplement_view_count, " +
                // ✅ reg_date 추가
                "       TO_CHAR(s.supplement_reg_date, 'YYYY-MM-DD') AS supplement_reg_date, " +
                "       COUNT(sl.supplement_like_id) AS like_cnt " +
                "FROM body_supplement bs " +
                // ✅ 실제 FK 기준: body_supplement.supplement_id = supplements.supplement_id
                "JOIN supplements s ON bs.supplement_id = s.supplement_id " +
                "LEFT JOIN supplements_like sl ON s.supplement_id = sl.supplement_id " +
                "WHERE bs.body_id = ? " +
                "GROUP BY s.supplement_id, " +
                "         s.supplement_name, " +
                "         s.supplement_efficacy, " +
                "         s.supplement_dosage, " +
                "         s.supplement_timing, " +
                "         s.supplement_caution, " +
                "         s.supplement_image_path, " +
                "         s.supplement_view_count, " +
                // ✅ GROUP BY에도 reg_date 추가
                "         s.supplement_reg_date " +
                "ORDER BY " + orderBy;

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, bodyId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BodyDTO dto = new BodyDTO();
                    dto.setSupplementId(rs.getInt("supplement_id"));
                    dto.setSupplementName(rs.getString("supplement_name"));
                    dto.setSupplementEfficacy(rs.getString("supplement_efficacy"));
                    dto.setSupplementDosage(rs.getString("supplement_dosage"));
                    dto.setSupplementTiming(rs.getString("supplement_timing"));
                    dto.setSupplementCaution(rs.getString("supplement_caution"));
                    dto.setSupplementImagePath(rs.getString("supplement_image_path"));
                    dto.setSupplementViewCount(rs.getInt("supplement_view_count"));
                    // ✅ reg_date 세팅
                    dto.setSupplementRegDate(rs.getString("supplement_reg_date"));
                    dto.setLikeCount(rs.getInt("like_cnt"));
                    list.add(dto);
                }
            }
        }
        return list;
    }

    // ─────────────────────────────────────────
    // 3. 영양소 상세 조회 + 조회수 증가
    // ─────────────────────────────────────────
    public BodyDTO getSupplementDetail(int supplementId) throws Exception {
        String updateSql = "UPDATE supplements " +
                "SET supplement_view_count = supplement_view_count + 1 " +
                "WHERE supplement_id = ?";

        String selectSql = "SELECT s.supplement_id, " +
                "       s.supplement_name, " +
                "       s.supplement_efficacy, " +
                "       s.supplement_dosage, " +
                "       s.supplement_timing, " +
                "       s.supplement_caution, " +
                "       s.supplement_image_path, " +
                "       s.supplement_view_count, " +
                // ✅ reg_date 추가
                "       TO_CHAR(s.supplement_reg_date, 'YYYY-MM-DD') AS supplement_reg_date, " +
                "       COUNT(sl.supplement_like_id) AS like_cnt " +
                "FROM supplements s " +
                "LEFT JOIN supplements_like sl ON s.supplement_id = sl.supplement_id " +
                "WHERE s.supplement_id = ? " +
                "GROUP BY s.supplement_id, " +
                "         s.supplement_name, " +
                "         s.supplement_efficacy, " +
                "         s.supplement_dosage, " +
                "         s.supplement_timing, " +
                "         s.supplement_caution, " +
                "         s.supplement_image_path, " +
                "         s.supplement_view_count, " +
                "         s.supplement_reg_date";

        try (Connection con = DBManager_new.connect()) {
            // 조회수 +1
            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setInt(1, supplementId);
                ps.executeUpdate();
            }
            // 상세 조회
            try (PreparedStatement ps = con.prepareStatement(selectSql)) {
                ps.setInt(1, supplementId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        BodyDTO dto = new BodyDTO();
                        dto.setSupplementId(rs.getInt("supplement_id"));
                        dto.setSupplementName(rs.getString("supplement_name"));
                        dto.setSupplementEfficacy(rs.getString("supplement_efficacy"));
                        dto.setSupplementDosage(rs.getString("supplement_dosage"));
                        dto.setSupplementTiming(rs.getString("supplement_timing"));
                        dto.setSupplementCaution(rs.getString("supplement_caution"));
                        dto.setSupplementImagePath(rs.getString("supplement_image_path"));
                        dto.setSupplementViewCount(rs.getInt("supplement_view_count"));
                        dto.setSupplementRegDate(rs.getString("supplement_reg_date"));
                        dto.setLikeCount(rs.getInt("like_cnt"));
                        return dto;
                    }
                }
            }
        }
        return null;
    }

    // ─────────────────────────────────────────
    // 4. 영양소 좋아요 토글
    // ─────────────────────────────────────────
    public boolean toggleSupplementLike(String userId, int supplementId) throws Exception {
        String checkSql  = "SELECT supplement_like_id FROM supplements_like " +
                "WHERE user_id = ? AND supplement_id = ?";
        String deleteSql = "DELETE FROM supplements_like " +
                "WHERE user_id = ? AND supplement_id = ?";

        // ✅ DB에 seq_supplement_like 시퀀스가 없다면 아래 SQL로 먼저 생성:
        //    CREATE SEQUENCE seq_supplement_like START WITH 1 INCREMENT BY 1;
        String insertSql = "INSERT INTO supplements_like " +
                "(supplement_like_id, user_id, supplement_id, supplement_like_date) " +
                "VALUES (seq_supplement_like.NEXTVAL, ?, ?, SYSDATE)";

        try (Connection con = DBManager_new.connect();
             PreparedStatement checkPs = con.prepareStatement(checkSql)) {

            checkPs.setString(1, userId);
            checkPs.setInt(2, supplementId);

            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next()) {
                    // 이미 좋아요 → 취소
                    try (PreparedStatement delPs = con.prepareStatement(deleteSql)) {
                        delPs.setString(1, userId);
                        delPs.setInt(2, supplementId);
                        delPs.executeUpdate();
                    }
                    return false;
                } else {
                    // 좋아요 추가
                    try (PreparedStatement insPs = con.prepareStatement(insertSql)) {
                        insPs.setString(1, userId);
                        insPs.setInt(2, supplementId);
                        insPs.executeUpdate();
                    }
                    return true;
                }
            }
        }
    }

    // ─────────────────────────────────────────
    // 5. 마이페이지 - 좋아요한 영양소 목록
    //    sortType: "recent"=최신순 / "popular"=인기순
    // ─────────────────────────────────────────
    public List<BodyDTO> getLikedSupplements(String userId, String sortType) throws Exception {
        List<BodyDTO> list = new ArrayList<>();

        String orderBy = "popular".equals(sortType)
                ? "total_likes DESC, sl.supplement_like_date DESC"
                : "sl.supplement_like_date DESC";

        String sql = "SELECT s.supplement_id, " +
                "       s.supplement_name, " +
                "       s.supplement_efficacy, " +
                "       s.supplement_image_path, " +
                "       s.supplement_view_count, " +
                "       TO_CHAR(s.supplement_reg_date, 'YYYY-MM-DD') AS supplement_reg_date, " +
                "       sl.supplement_like_date, " +
                "       (SELECT COUNT(*) FROM supplements_like sl2 " +
                "        WHERE sl2.supplement_id = s.supplement_id) AS total_likes " +
                "FROM supplements_like sl " +
                "JOIN supplements s ON sl.supplement_id = s.supplement_id " +
                // ✅ users 테이블과 JOIN 가능하나 현재는 userId로만 필터링
                "WHERE sl.user_id = ? " +
                "ORDER BY " + orderBy;

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BodyDTO dto = new BodyDTO();
                    dto.setSupplementId(rs.getInt("supplement_id"));
                    dto.setSupplementName(rs.getString("supplement_name"));
                    dto.setSupplementEfficacy(rs.getString("supplement_efficacy"));
                    dto.setSupplementImagePath(rs.getString("supplement_image_path"));
                    dto.setSupplementViewCount(rs.getInt("supplement_view_count"));
                    dto.setSupplementRegDate(rs.getString("supplement_reg_date"));
                    dto.setLikeCount(rs.getInt("total_likes"));
                    list.add(dto);
                }
            }
        }
        return list;
    }
}