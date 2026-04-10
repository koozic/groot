package com.groot.app.body;

import com.groot.app.body.BodyDTO;
import com.groot.app.main.DBManager_new;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminDAO {

    public boolean checkIsAdmin(String userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM admin WHERE admin_id = ?"; // AdminDTO의 adminId 필드와 매핑되는 컬럼명
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    // ── 전체 영양소 목록 (관리자용) ──
//    public List<BodyDTO> getAllSupplements() throws Exception {
//        List<BodyDTO> list = new ArrayList<>();
//        String sql = "SELECT supplement_id, supplement_name, supplement_efficacy, " +
//                "       supplement_dosage, supplement_timing, supplement_caution, " +
//                "       supplement_image_path, supplement_view_count, " +
//                "       TO_CHAR(supplement_reg_date, 'YYYY-MM-DD') AS supplement_reg_date " +
//                "FROM supplements " +
//                "ORDER BY supplement_id DESC";
//
//        try (Connection con = DBManager_new.connect();
//             PreparedStatement ps = con.prepareStatement(sql);
//             ResultSet rs = ps.executeQuery()) {
//
//            while (rs.next()) {
//                BodyDTO dto = new BodyDTO();
//                dto.setSupplementId(rs.getInt("supplement_id"));
//                dto.setSupplementName(rs.getString("supplement_name"));
//                dto.setSupplementEfficacy(rs.getString("supplement_efficacy"));
//                dto.setSupplementDosage(rs.getString("supplement_dosage"));
//                dto.setSupplementTiming(rs.getString("supplement_timing"));
//                dto.setSupplementCaution(rs.getString("supplement_caution"));
//                dto.setSupplementImagePath(rs.getString("supplement_image_path"));
//                dto.setSupplementViewCount(rs.getInt("supplement_view_count"));
//                dto.setSupplementRegDate(rs.getString("supplement_reg_date"));
//                list.add(dto);
//            }
//        }
//        return list;
//    }

    // 기존 메서드는 그대로 두고, 아래 메서드를 추가합니다.

    /**
     * 정렬 조건을 받아 전체 영양소 목록을 반환합니다.
     * sortBy:
     * "id_desc"   → 최신 등록순 (supplement_id DESC) — 기본값
     * "id_asc"    → 오래된 등록순 (supplement_id ASC)
     * "date_desc" → 등록일 최신순 (supplement_reg_date DESC)
     * "date_asc"  → 등록일 오래된순 (supplement_reg_date ASC)
     * "name_asc"  → 이름 가나다순 (supplement_name ASC)
     */
    public List<BodyDTO> getAllSupplements(String sortBy) throws Exception {

        // ── 허용된 정렬 값만 사용 (SQL Injection 방지) ──
        String orderBy;
        switch (sortBy == null ? "" : sortBy) {
            case "id_asc":
                orderBy = "supplement_id ASC";
                break;
            case "date_desc":
                orderBy = "supplement_reg_date DESC";
                break;
            case "date_asc":
                orderBy = "supplement_reg_date ASC";
                break;
            case "name_asc":
                orderBy = "supplement_name ASC";
                break;
            default:
                orderBy = "supplement_id DESC";
                break; // id_desc
        }

        String sql = "SELECT supplement_id, supplement_name, supplement_efficacy, " +
                "       supplement_dosage, supplement_timing, supplement_caution, " +
                "       supplement_image_path, supplement_view_count, " +
                "       TO_CHAR(supplement_reg_date, 'YYYY-MM-DD') AS supplement_reg_date " +
                "FROM supplements " +
                "ORDER BY " + orderBy;

        List<BodyDTO> list = new ArrayList<>();
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

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
                dto.setSupplementRegDate(rs.getString("supplement_reg_date"));
                list.add(dto);
            }
        }
        return list;
    }

    // 기존 파라미터 없는 메서드는 내부에서 위 메서드를 호출하도록 수정 (하위 호환)
    public List<BodyDTO> getAllSupplements() throws Exception {
        return getAllSupplements("id_desc");
    }

    // ── 단일 영양소 조회 (수정 폼용) ──
    public BodyDTO getSupplementById(int supplementId) throws Exception {
        String sql = "SELECT supplement_id, supplement_name, supplement_efficacy, " +
                "       supplement_dosage, supplement_timing, supplement_caution, " +
                "       supplement_image_path, supplement_view_count, " +
                "       TO_CHAR(supplement_reg_date, 'YYYY-MM-DD') AS supplement_reg_date " +
                "FROM supplements " +
                "WHERE supplement_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

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
                    return dto;
                }
            }
        }
        return null;
    }

    // ── 영양소 등록 ──
    public void insertSupplement(BodyDTO dto) throws Exception {
        // supplements 테이블 PK용 시퀀스명을 실제 DB에 맞게 변경하세요
        // 없으면: CREATE SEQUENCE seq_supplements START WITH 1 INCREMENT BY 1;
        String sql = "INSERT INTO supplements " +
                "(supplement_id, supplement_name, supplement_efficacy, " +
                " supplement_dosage, supplement_timing, supplement_caution, " +
                " supplement_image_path, supplement_view_count, supplement_reg_date) " +
                "VALUES (seq_supplements.NEXTVAL, ?, ?, ?, ?, ?, ?, 0, SYSDATE)";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql, new String[]{"SUPPLEMENT_ID"})) { // 생성된 ID 반환받기

            ps.setString(1, dto.getSupplementName());
            ps.setString(2, dto.getSupplementEfficacy());
            ps.setString(3, dto.getSupplementDosage());
            ps.setString(4, dto.getSupplementTiming());
            ps.setString(5, dto.getSupplementCaution());
            ps.setString(6, dto.getSupplementImagePath());
            ps.executeUpdate();

            // 등록된 supplement_id를 dto에 저장 (body_supplement 연결에 사용)
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    dto.setSupplementId(keys.getInt(1));
                }
            }
        }
    }

    // ── body_supplement 연결 추가 ──
    public void linkBodySupplement(int bodyId, int supplementId) throws Exception {
        String sql = "INSERT INTO body_supplement (body_id, supplement_id) VALUES (?, ?)";
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bodyId);
            ps.setInt(2, supplementId);
            ps.executeUpdate();
        }
    }

    // ── 영양소 수정 ──
    public void updateSupplement(BodyDTO dto) throws Exception {
        String sql = "UPDATE supplements SET " +
                "supplement_name = ?, " +
                "supplement_efficacy = ?, " +
                "supplement_dosage = ?, " +
                "supplement_timing = ?, " +
                "supplement_caution = ?, " +
                "supplement_image_path = ? " +
                "WHERE supplement_id = ?";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, dto.getSupplementName());
            ps.setString(2, dto.getSupplementEfficacy());
            ps.setString(3, dto.getSupplementDosage());
            ps.setString(4, dto.getSupplementTiming());
            ps.setString(5, dto.getSupplementCaution());
            ps.setString(6, dto.getSupplementImagePath());
            ps.setInt(7, dto.getSupplementId());
            ps.executeUpdate();
        }
    }

    // ── 삭제 전 body_supplement 연결 해제 ──
    public void deleteBodySupplementLinks(int supplementId) throws Exception {
        String sql = "DELETE FROM body_supplement WHERE supplement_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, supplementId);
            ps.executeUpdate();
        }
    }

    // ── 삭제 전 supplements_like 제거 ──
    public void deleteSupplementLikes(int supplementId) throws Exception {
        String sql = "DELETE FROM supplements_like WHERE supplement_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, supplementId);
            ps.executeUpdate();
        }
    }

    // ── 영양소 삭제 ──
    public void deleteSupplement(int supplementId) throws Exception {
        String sql = "DELETE FROM supplements WHERE supplement_id = ?";
        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, supplementId);
            ps.executeUpdate();
        }
    }
}