package com.groot.app.review;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import javax.servlet.http.HttpServletRequest;
import com.groot.app.main.DBManager_new;
import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

public class ReviewDAO {
    // 1. 싱글톤 패턴
    public static final ReviewDAO RDAO = new ReviewDAO();

    private ReviewDAO() {}

    private ArrayList<ReviewDTO> reviews;


    public void getAllReview(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // 1. 쿼리문 (특정 상품의 리뷰만 가져오기 위해 WHERE절 추가!)
        String sql = "SELECT * FROM REVIEWS WHERE PRODUCT_ID = ? ORDER BY R_DATE DESC";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);

            // 컨트롤러가 넘겨준 리퀘스트에서 상품 ID 꺼내서 쿼리 완성!
            pstmt.setString(1, request.getParameter("PRODUCT_ID"));

            rs = pstmt.executeQuery();

            // 2. 쌤 스타일: 그릇(DTO) 재사용 준비랑 리스트 만들기
            ReviewDTO dto = null;
           reviews = new ArrayList<>();

            // 3. 데이터 뺑뺑이 돌리면서 하나씩 담기
            while (rs.next()) {
                dto = new ReviewDTO(); // 빈 도시락통 꺼내기

                // 컬럼명 보고 하나씩 set 해주기 (롬복이 이거 만들어주니까 개꿀!)
                dto.setReview_id(rs.getInt("REVIEW_ID"));
                dto.setUser_id(rs.getString("USER_ID"));
                dto.setProduct_id(rs.getInt("PRODUCT_ID"));
                dto.setR_title(rs.getString("R_TITLE"));
                dto.setR_content(rs.getString("R_CONTENT"));
                dto.setR_score(rs.getInt("R_SCORE"));
                dto.setR_img(rs.getString("R_IMG"));
                dto.setR_date(rs.getDate("R_DATE"));
                dto.setR_like(rs.getInt("R_LIKE"));

                reviews.add(dto); // 완성된 도시락을 리스트에 추가!
            }

            // 4. 잘 담겼나 확인용 출력 (쌤 스타일 ㅋㅋㅋ)
            System.out.println("가져온 리뷰 개수: " + reviews.size());

            // 5. 가방(request)에 "reviews"라는 이름으로 전달!
            request.setAttribute("reviews", reviews);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // 닫는 것도 깔끔하게!
            DBManager_new.close(con, pstmt, rs);
        }

    }

    public void insertReview(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;

        try {
            // 1. 사진 저장 경로 잡기
            String path = request.getServletContext().getRealPath("upload");
            System.out.println("사진 저장 폴더: " + path);

            // 2. 🌟 언박싱 시작! (MultipartRequest 객체 생성)
            MultipartRequest mr = new MultipartRequest(request, path, 1024 * 1024 * 10, "UTF-8", new DefaultFileRenamePolicy());
//
            // 3. 박스에서 내용물(파라미터) 하나씩 꺼내기
            String product_id = mr.getParameter("product_id");
            String r_title = mr.getParameter("r_title");
            String r_score = mr.getParameter("r_score");
            String r_content = mr.getParameter("r_content");

            // 실제 올라간 사진 파일 이름 꺼내기
            String r_img = mr.getFilesystemName("r_img");

            String user_id = "kim123"; // 임시 유저 아이디

            // 줄바꿈 처리 (엔터 친 거 화면에서도 줄바꿈 되게!)
            r_content = r_content.replaceAll("\r\n", "<br>");

            // 4. 🌟 컨트롤러에서 getParameter를 못 쓰니까, 대신 쓰라고 가방에 넣어줌!
            // (이게 쌤 코드의 request.setAttribute("noo", no)랑 똑같은 역할이야!)
            request.setAttribute("p_id", product_id);

            // 5. DB 연결 및 INSERT
            con = DBManager_new.connect();
            String sql = "INSERT INTO reviews (review_id, user_id, product_id, r_title, r_content, r_score, r_img, r_date, r_like) " +
                    "VALUES (reviews_seq.NEXTVAL, ?, ?, ?, ?, ?, ?, SYSDATE, 0)";

            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, user_id);
            pstmt.setInt(2, Integer.parseInt(product_id));
            pstmt.setString(3, r_title);
            pstmt.setString(4, r_content);
            pstmt.setInt(5, Integer.parseInt(r_score));
            pstmt.setString(6, r_img);

            // 6. 쿼리 실행
            if (pstmt.executeUpdate() == 1) {
                System.out.println("✅ 리뷰 작성(언박싱 완료) 대성공!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("❌ 리뷰 작성 에러 발생!");
        } finally {
            DBManager_new.close(con, pstmt, null);
        }



    }
} // ReviewDAO 클래스 끝