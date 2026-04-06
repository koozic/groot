package com.groot.app.supplements;

// DAO 역할 : DB에 접속해서 전체 영양성분 리스트를 조회(SELECT)한 뒤,
// 여러 개의 SupplementDTO를 리스트(List)에 담아 반환하는 역할

import com.groot.app.main.DBManager_new;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SupplementsDAO {

    // 영양성분 전체 리스트 조회 메서드 (Read)
    public static List<SupplementsDTO> getSupplementsList() {
        List<SupplementsDTO> SupplementList = new ArrayList<>();

        // 처음 주셨던 SQL 테이블명과 컬럼명에 맞게 쿼리 수정 (최신순 정렬)
        String sql = "SELECT * FROM supplements ORDER BY supplement_id DESC";

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                SupplementsDTO dto = new SupplementsDTO();

                // 처음 주신 SQL 컬럼명(supplement_id 등)에 맞게 꺼내기
                // (DTO의 Setter 이름은 본인이 만든 클래스에 맞게 수정하세요)
                dto.setSupplementId(rs.getInt("supplement_id"));
                dto.setSupplementName(rs.getString("supplement_name"));
                dto.setSupplementEfficacy(rs.getString("supplement_efficacy"));
                dto.setSupplementImagePath(rs.getString("supplement_image_path"));

                // 데이터가 담긴 DTO를 List에 추가
                SupplementList.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }

        return SupplementList;
    }

}



