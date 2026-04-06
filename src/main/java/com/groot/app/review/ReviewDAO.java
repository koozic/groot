package com.groot.app.review;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
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
    // 🌟 [추가] 상품별 별점 통계 가져오기
    public static Map<Integer, Integer> getStarStats(int productId) {
        // 별점(key)과 개수(value)를 담을 주머니
        Map<Integer, Integer> stats = new HashMap<>();

        // 기본값 0으로 세팅 (안 그러면 리뷰 없는 점수는 맵에 안 담겨서 JSP에서 에러 남 ㅋㅋㅋ)
        for (int i = 1; i <= 5; i++) stats.put(i, 0);

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBManager_new.connect();
            // SQL 포인트: r_score로 그룹 묶어서 개수(COUNT) 세기!
            // ReviewDAO.java 약 147번 줄 근처
            // 💡 이렇게 끝에 공백(Space)을 한 칸씩 꼭 넣어!
            String sql = "SELECT r_score, COUNT(*) as cnt " + // 👈 cnt 뒤에 공백!
                    "FROM REVIEWS " +                    // 👈 REVIEWS 뒤에 공백!
                    "WHERE product_id = ? " +            // 👈 ? 뒤에 공백!
                    "GROUP BY r_score";

            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                // DB에서 가져온 점수랑 개수를 맵에 업데이트!
                System.out.println(">>> DB에서 꺼낸 별점: " + rs.getInt("r_score") + ", 개수: " + rs.getInt("cnt"));
                stats.put(rs.getInt("r_score"), rs.getInt("cnt"));

            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return stats;
    }

    // 🌟 [근본] 상품의 평균 별점 가져오기
    public static double getAvgScore(int productId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        double avg = 0.0;

        try {
            con = DBManager_new.connect();
            // 🌟 쿼리 포인트: AVG(r_score) 쓰면 오라클이 알아서 다 더하고 나눠줌!
            // NVL은 리뷰가 0개일 때 널(null) 에러 안 나게 0으로 바꿔주는 센스!
            String sql = "SELECT NVL(AVG(r_score), 0) as avg_score FROM REVIEWS WHERE product_id = ?";

            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                avg = rs.getDouble("avg_score");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return avg;
    }
    // ReviewDAO.java 에 추가 (또는 기존 getStarStats 수정)
    public static void getReviewStats(HttpServletRequest request, int productId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // 별점별 개수를 담을 맵 (기본값 0 세팅)
        Map<Integer, Integer> stats = new HashMap<>();
        for (int i = 1; i <= 5; i++) stats.put(i, 0);

        try {
            con = DBManager_new.connect();

            // 🌟 쿼리 한 줄로 평균(AVG)과 별점별 그룹화 데이터를 다 가져올 순 없으니,
            // 여기서는 통계 데이터를 정교하게 가져오는 게 포인트!
            String sql = "SELECT r_score, COUNT(*) as cnt FROM REVIEWS WHERE product_id = ? GROUP BY r_score";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();

            double totalScoreSum = 0;
            int totalReviewCount = 0;

            while (rs.next()) {
                int score = rs.getInt("r_score");
                int cnt = rs.getInt("cnt");
                stats.put(score, cnt);

                totalScoreSum += (score * cnt); // 점수 합계 계산
                totalReviewCount += cnt;        // 전체 개수 계산
            }

            // 🌟 계산 로직을 DAO가 다 처리함!
            double avg = (totalReviewCount > 0) ? (totalScoreSum / totalReviewCount) : 0.0;
            String avgScore = String.format("%.1f", avg);

            // 🌟 결과물을 바로 request 가방에 넣어버림 (컨트롤러 일거리 줄여주기)
            request.setAttribute("starStats", stats);
            request.setAttribute("avgScore", avgScore);
            request.setAttribute("totalCount", totalReviewCount);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
    }
} // ReviewDAO 클래스 끝