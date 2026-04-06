package com.groot.app.body;

import com.groot.app.main.DBManager_new;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BodyDAO {

    // ─────────────────────────────────────────
    // 1. 모든 신체 부위 목록 조회 (body.jsp 초기 렌더링용)
    // ─────────────────────────────────────────
    public List<BodyDTO> getAllBodies() throws Exception {
        List<BodyDTO> list = new ArrayList<>();
        String sql = "SELECT body_id, body_name, body_image FROM body ORDER BY body_id";

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
    //    sortType: "view" = 조회순 / "like" = 좋아요순
    // ─────────────────────────────────────────
    public List<BodyDTO> getSupplementsByBody(int bodyId, String sortType) throws Exception {
        List<BodyDTO> list = new ArrayList<>();

        // 좋아요 수는 supplements_like 테이블에서 COUNT
        String orderBy = "like".equals(sortType)
                ? "like_cnt DESC, s.supplement_view_count DESC"
                : "s.supplement_view_count DESC, like_cnt DESC";

        String sql = "SELECT s.supplement_id, s.supplement_name, s.supplement_efficacy, " +
                "       s.supplement_dosage, s.supplement_timing, s.supplement_caution, " +
                "       s.supplement_image_path, s.supplement_view_count, " +
                "       COUNT(sl.supplement_like_id) AS like_cnt " +
                "FROM body_supplement bs " +
                "JOIN supplements s ON bs.supplement_id = s.supplement_id " +
                "LEFT JOIN supplements_like sl ON s.supplement_id = sl.supplement_id " +
                "WHERE bs.body_id = ? " +
                "GROUP BY s.supplement_id, s.supplement_name, s.supplement_efficacy, " +
                "         s.supplement_dosage, s.supplement_timing, s.supplement_caution, " +
                "         s.supplement_image_path, s.supplement_view_count " +
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
                    dto.setLikeCount(rs.getInt("like_cnt"));
                    list.add(dto);
                }
            }
        }
        return list;
    }

    // ─────────────────────────────────────────
    // 3. 영양소 상세 조회 + 조회수 증가 (클릭 시)
    // ─────────────────────────────────────────
    public BodyDTO getSupplementDetail(int supplementId) throws Exception {
        // 조회수 먼저 +1
        String updateSql = "UPDATE supplements SET supplement_view_count = supplement_view_count + 1 " +
                "WHERE supplement_id = ?";

        String selectSql = "SELECT s.supplement_id, s.supplement_name, s.supplement_efficacy, " +
                "       s.supplement_dosage, s.supplement_timing, s.supplement_caution, " +
                "       s.supplement_image_path, s.supplement_view_count, " +
                "       COUNT(sl.supplement_like_id) AS like_cnt " +
                "FROM supplements s " +
                "LEFT JOIN supplements_like sl ON s.supplement_id = sl.supplement_id " +
                "WHERE s.supplement_id = ? " +
                "GROUP BY s.supplement_id, s.supplement_name, s.supplement_efficacy, " +
                "         s.supplement_dosage, s.supplement_timing, s.supplement_caution, " +
                "         s.supplement_image_path, s.supplement_view_count";

        try (Connection con = DBManager_new.connect()) {
            // 조회수 업데이트
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
                        dto.setLikeCount(rs.getInt("like_cnt"));
                        return dto;
                    }
                }
            }
        }
        return null;
    }

    // ─────────────────────────────────────────
    // 4. 영양소 좋아요 토글 (있으면 삭제, 없으면 추가)
    //    반환값: true = 좋아요 추가됨 / false = 좋아요 취소됨
    // ─────────────────────────────────────────
    public boolean toggleSupplementLike(String userId, int supplementId) throws Exception {
        String checkSql = "SELECT supplement_like_id FROM supplements_like " +
                "WHERE user_id = ? AND supplement_id = ?";
        String deleteSql = "DELETE FROM supplements_like WHERE user_id = ? AND supplement_id = ?";
        String insertSql = "INSERT INTO supplements_like (supplement_like_id, user_id, supplement_id, supplement_like_date) " +
                "VALUES (seq_supplement_like.NEXTVAL, ?, ?, SYSDATE)";
        // ※ seq_supplement_like 시퀀스가 없다면 DB에서 생성 필요:
        //   CREATE SEQUENCE seq_supplement_like START WITH 1 INCREMENT BY 1;

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
    // 5. 특정 유저가 좋아요한 영양소 목록 (마이페이지용)
    //    sortType: "recent" = 최신순 / "popular" = 인기순
    // ─────────────────────────────────────────
    public List<BodyDTO> getLikedSupplements(String userId, String sortType) throws Exception {
        List<BodyDTO> list = new ArrayList<>();

        String orderBy = "popular".equals(sortType)
                ? "total_likes DESC, sl.supplement_like_date DESC"
                : "sl.supplement_like_date DESC";

        String sql = "SELECT s.supplement_id, s.supplement_name, s.supplement_efficacy, " +
                "       s.supplement_image_path, s.supplement_view_count, " +
                "       sl.supplement_like_date, " +
                "       (SELECT COUNT(*) FROM supplements_like sl2 " +
                "        WHERE sl2.supplement_id = s.supplement_id) AS total_likes " +
                "FROM supplements_like sl " +
                "JOIN supplements s ON sl.supplement_id = s.supplement_id " +
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
                    dto.setLikeCount(rs.getInt("total_likes"));
                    list.add(dto);
                }
            }
        }
        return list;
    }
}