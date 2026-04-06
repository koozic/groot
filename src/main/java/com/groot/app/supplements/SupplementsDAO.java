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
        List<SupplementsDTO> list = new ArrayList<>();

        // 최신 등록된 영양성분이 먼저 나오도록 내림차순(DESC) 정렬
        String sql = "SELECT * FROM supplements ORDER BY s_no DESC";

        // finally 블록에서 자원을 해제하기 위해 변수를 try 블록 밖에서 선언
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // 1. DBManager_new를 통해 커넥션 풀에서 커넥션 대여
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            // 2. DB에서 꺼내온 데이터가 있는 동안 계속 반복
            while (rs.next()) {
                SupplementsDTO dto = new SupplementsDTO();

                // ResultSet에서 데이터를 꺼내어 DTO 바구니에 담기
//                dto.setsNo(rs.getInt("s_no"));
//                dto.setsName(rs.getString("s_name"));
//                dto.setsEfficacy(rs.getString("s_efficacy"));
//                dto.setsImagePath(rs.getString("s_image_path"));
//                dto.setsRegDate(rs.getDate("s_reg_date"));
//                dto.setsViewCount(rs.getInt("s_view_count"));

                // 데이터가 담긴 DTO를 List에 추가
                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // 3. DBManager_new의 close 메서드를 사용하여 자원 반납 (안전하게 커넥션 풀로 돌려보냄)
            DBManager_new.close(con, pstmt, rs);
        }

        return list; // 완성된 리스트 반환

    }

    public void getSupplementsList(HttpServletRequest request) {
    }
}



