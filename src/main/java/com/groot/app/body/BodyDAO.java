package com.groot.app.body;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.groot.app.main.DBManager_new;

public class BodyDAO {
    
    // CREATE - 새로운 신체 부위 추가
    public int insert(BodyDTO dto) throws SQLException {
        String sql = "INSERT INTO body (body_id, body_name, body_image) VALUES (seq_body.NEXTVAL, ?, ?)";
        
        try (Connection conn = DBManager_new.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql, new String[] {"body_id"})) {
            
            pstmt.setString(1, dto.getBodyName());
            pstmt.setString(2, dto.getBodyImage());
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
            return result;
        }
    }
    
    // READ - 단일 신체 부위 조회
    public BodyDTO select(int bodyId) throws SQLException {
        String sql = "SELECT body_id, body_name, body_image FROM body WHERE body_id = ?";
        
        try (Connection conn = DBManager_new.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bodyId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    BodyDTO dto = new BodyDTO();
                    dto.setBodyId(rs.getInt("body_id"));
                    dto.setBodyName(rs.getString("body_name"));
                    dto.setBodyImage(rs.getString("body_image"));
                    return dto;
                }
            }
        }
        return null;
    }
    
    // READ ALL - 전체 신체 부위 조회
    public List<BodyDTO> selectAll() throws SQLException {
        String sql = "SELECT body_id, body_name, body_image FROM body ORDER BY body_id";
        List<BodyDTO> list = new ArrayList<>();
        
        try (Connection conn = DBManager_new.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
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
    
    // UPDATE - 신체 부위 정보 수정
    public int update(BodyDTO dto) throws SQLException {
        String sql = "UPDATE body SET body_name = ?, body_image = ? WHERE body_id = ?";
        
        try (Connection conn = DBManager_new.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, dto.getBodyName());
            pstmt.setString(2, dto.getBodyImage());
            pstmt.setInt(3, dto.getBodyId());
            
            return pstmt.executeUpdate();
        }
    }
    
    // DELETE - 신체 부위 삭제
    public int delete(int bodyId) throws SQLException {
        String sql = "DELETE FROM body WHERE body_id = ?";
        
        try (Connection conn = DBManager_new.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bodyId);
            return pstmt.executeUpdate();
        }
    }
    
    // 이름으로 조회
    public BodyDTO selectByName(String bodyName) throws SQLException {
        String sql = "SELECT body_id, body_name, body_image FROM body WHERE body_name = ?";
        
        try (Connection conn = DBManager_new.connect();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, bodyName);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    BodyDTO dto = new BodyDTO();
                    dto.setBodyId(rs.getInt("body_id"));
                    dto.setBodyName(rs.getString("body_name"));
                    dto.setBodyImage(rs.getString("body_image"));
                    return dto;
                }
            }
        }
        return null;
    }

}
