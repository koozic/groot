package com.groot.app.curation;

import com.groot.app.main.DBManager_new;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CurationDAO {

    // ─────────────────────────────────────────
    // 큐레이션 목록 조회 (전체, 북마크 여부 포함)
    // ─────────────────────────────────────────
    public List<CurationDTO> getAllCurations(String userId) throws Exception {
        List<CurationDTO> list = new ArrayList<>();

        // userId가 있으면 북마크 여부도 같이 조회
        String sql = "SELECT c.curation_id, c.curation_name, c.curation_description, " +
                "       c.view_count, c.like_count, c.curation_image, c.user_id, " +
                "       CASE WHEN cl.curation_like_id IS NOT NULL THEN 1 ELSE 0 END AS bookmarked " +
                "FROM curation c " +
                "LEFT JOIN curation_likes cl ON c.curation_id = cl.curation_id AND cl.user_id = ? " +
                "ORDER BY c.curation_id DESC";

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, userId != null ? userId : "");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CurationDTO dto = new CurationDTO();
                    dto.setCurationId(rs.getInt("curation_id"));
                    dto.setCurationName(rs.getString("curation_name"));
                    dto.setCurationDescription(rs.getString("curation_description"));
                    dto.setViewCount(rs.getInt("view_count"));
                    dto.setLikeCount(rs.getInt("like_count"));
                    dto.setCurationImage(rs.getString("curation_image"));
                    dto.setUserId(rs.getString("user_id"));
                    dto.setBookmarked(rs.getInt("bookmarked") == 1);
                    list.add(dto);
                }
            }
        }
        return list;
    }

    // ─────────────────────────────────────────
    // 큐레이션 상세 + 조회수 증가
    // ─────────────────────────────────────────
    public CurationDTO getCurationDetail(int curationId, String userId) throws Exception {
        String updateSql = "UPDATE curation SET view_count = view_count + 1 WHERE curation_id = ?";
        String selectSql = "SELECT c.curation_id, c.curation_name, c.curation_description, " +
                "       c.view_count, c.like_count, c.curation_image, c.user_id, " +
                "       CASE WHEN cl.curation_like_id IS NOT NULL THEN 1 ELSE 0 END AS bookmarked " +
                "FROM curation c " +
                "LEFT JOIN curation_likes cl ON c.curation_id = cl.curation_id AND cl.user_id = ? " +
                "WHERE c.curation_id = ?";

        try (Connection con = DBManager_new.connect()) {
            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                ps.setInt(1, curationId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement(selectSql)) {
                ps.setString(1, userId != null ? userId : "");
                ps.setInt(2, curationId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        CurationDTO dto = new CurationDTO();
                        dto.setCurationId(rs.getInt("curation_id"));
                        dto.setCurationName(rs.getString("curation_name"));
                        dto.setCurationDescription(rs.getString("curation_description"));
                        dto.setViewCount(rs.getInt("view_count"));
                        dto.setLikeCount(rs.getInt("like_count"));
                        dto.setCurationImage(rs.getString("curation_image"));
                        dto.setUserId(rs.getString("user_id"));
                        dto.setBookmarked(rs.getInt("bookmarked") == 1);
                        return dto;
                    }
                }
            }
        }
        return null;
    }

    // ─────────────────────────────────────────
    // 큐레이션 북마크(좋아요) 토글
    // ─────────────────────────────────────────
    public boolean toggleBookmark(String userId, int curationId) throws Exception {
        String checkSql = "SELECT curation_like_id FROM curation_likes WHERE user_id = ? AND curation_id = ?";
        String deleteSql = "DELETE FROM curation_likes WHERE user_id = ? AND curation_id = ?";
        String insertSql = "INSERT INTO curation_likes (curation_like_id, user_id, curation_id, created_at) " +
                "VALUES (seq_curation_likes.NEXTVAL, ?, ?, SYSDATE)";
        String updateLikeSql = "UPDATE curation SET like_count = like_count + ? WHERE curation_id = ?";

        try (Connection con = DBManager_new.connect()) {
            con.setAutoCommit(false);
            boolean added;

            try (PreparedStatement checkPs = con.prepareStatement(checkSql)) {
                checkPs.setString(1, userId);
                checkPs.setInt(2, curationId);

                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        // 북마크 취소
                        try (PreparedStatement delPs = con.prepareStatement(deleteSql)) {
                            delPs.setString(1, userId);
                            delPs.setInt(2, curationId);
                            delPs.executeUpdate();
                        }
                        added = false;
                    } else {
                        // 북마크 추가
                        try (PreparedStatement insPs = con.prepareStatement(insertSql)) {
                            insPs.setString(1, userId);
                            insPs.setInt(2, curationId);
                            insPs.executeUpdate();
                        }
                        added = true;
                    }
                }
            }

            // like_count 동기화
            try (PreparedStatement updatePs = con.prepareStatement(updateLikeSql)) {
                updatePs.setInt(1, added ? 1 : -1);
                updatePs.setInt(2, curationId);
                updatePs.executeUpdate();
            }

            con.commit();
            return added;
        }
    }

    // ─────────────────────────────────────────
    // 마이페이지: 북마크한 큐레이션 목록
    //   sortType: "recent" = 최신순 / "popular" = 인기순(like_count)
    // ─────────────────────────────────────────
    public List<CurationDTO> getBookmarkedCurations(String userId, String sortType) throws Exception {
        List<CurationDTO> list = new ArrayList<>();

        String orderBy = "popular".equals(sortType)
                ? "c.like_count DESC, cl.created_at DESC"
                : "cl.created_at DESC";

        String sql = "SELECT c.curation_id, c.curation_name, c.curation_description, " +
                "       c.view_count, c.like_count, c.curation_image, c.user_id " +
                "FROM curation_likes cl " +
                "JOIN curation c ON cl.curation_id = c.curation_id " +
                "WHERE cl.user_id = ? " +
                "ORDER BY " + orderBy;

        try (Connection con = DBManager_new.connect();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CurationDTO dto = new CurationDTO();
                    dto.setCurationId(rs.getInt("curation_id"));
                    dto.setCurationName(rs.getString("curation_name"));
                    dto.setCurationDescription(rs.getString("curation_description"));
                    dto.setViewCount(rs.getInt("view_count"));
                    dto.setLikeCount(rs.getInt("like_count"));
                    dto.setCurationImage(rs.getString("curation_image"));
                    dto.setUserId(rs.getString("user_id"));
                    dto.setBookmarked(true); // 이 목록은 무조건 북마크됨
                    list.add(dto);
                }
            }
        }
        return list;
    }
}