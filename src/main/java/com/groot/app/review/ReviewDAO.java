package com.groot.app.review;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.groot.app.main.DBManager_new;
import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

public class ReviewDAO {
    // 1. 싱글톤 패턴
    public static final ReviewDAO RDAO = new ReviewDAO();

    private ReviewDAO() {
    }

    private ArrayList<ReviewDTO> reviews;


    // 정렬(sortType)과 별점필터(starFilter)를 적용한 전체 리뷰 가져오기
    public void getAllReview(HttpServletRequest request, int productId, String sortType, int starFilter) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // 1. 기본 쿼리 (특정 상품의 리뷰)
        String sql = "SELECT * FROM REVIEWS WHERE PRODUCT_ID = ?";

        // 2. 별점 필터링 조건 추가 (예: 5점만 보기)
        if (starFilter > 0) {
            sql += " AND R_SCORE = " + starFilter;
        }

        // 3. 정렬 및 필터 조건 추가 (ORDER BY)
        if ("like".equals(sortType)) {
            sql += " ORDER BY R_LIKE DESC, R_DATE DESC"; // 좋아요순

        } else if ("photo".equals(sortType)) {
            // 🌟 99년생 에이스 무영이가 추가할 부분!
            // 📸 사진이 있는(R_IMG가 NULL이 아닌) 리뷰만 골라내고 최신순 정렬!
            sql += " AND R_IMG IS NOT NULL ORDER BY R_DATE DESC";

        } else if ("high_score".equals(sortType)) {
            sql += " ORDER BY R_SCORE DESC, R_DATE DESC"; // 평점 높은순

        } else if ("low_score".equals(sortType)) {
            sql += " ORDER BY R_SCORE ASC, R_DATE DESC";  // 평점 낮은순

        } else {
            // ❌ 기존: sql += " ORDER BY R_DATE DESC"; (최신순)
            // ✅ 수정: 베스트순(좋아요순)을 기본값으로 설정!
            sql += " ORDER BY R_LIKE DESC, R_DATE DESC";
        }

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();

            ArrayList<ReviewDTO> reviews = new ArrayList<>();
            while (rs.next()) {
                ReviewDTO dto = new ReviewDTO();
                dto.setReview_id(rs.getInt("REVIEW_ID"));
                dto.setUser_id(rs.getString("USER_ID"));
                dto.setProduct_id(rs.getInt("PRODUCT_ID"));
                dto.setR_title(rs.getString("R_TITLE"));
                dto.setR_content(rs.getString("R_CONTENT"));
                dto.setR_score(rs.getInt("R_SCORE"));
                dto.setR_img(rs.getString("R_IMG"));
                dto.setR_date(rs.getDate("R_DATE"));
                dto.setR_like(rs.getInt("R_LIKE"));
                reviews.add(dto);
            }
            // JSP에서 쓸 수 있게 리퀘스트에 담기
            request.setAttribute("reviews", reviews);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
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

            String user_id = "kim124"; // 임시 유저 아이디

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

    // 특정 상품의 '사진이 있는' 리뷰 이미지만 가져오기
    // 특정 상품의 '사진이 있는' 리뷰 가져오기 (모달 띄우기 위해 모든 정보 다 가져옴!)
    public ArrayList<ReviewDTO> getAllPhotoImages(int productId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList<ReviewDTO> images = new ArrayList<>();

        // 🌟 수정: SELECT * 로 변경!
        String sql = "SELECT * FROM REVIEWS WHERE PRODUCT_ID = ? AND R_IMG IS NOT NULL ORDER BY R_DATE DESC";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, productId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ReviewDTO dto = new ReviewDTO();
                // 🌟 수정: 모달에 띄워야 하니까 정보 다 챙기기!
                dto.setReview_id(rs.getInt("REVIEW_ID"));
                dto.setUser_id(rs.getString("USER_ID"));
                dto.setProduct_id(rs.getInt("PRODUCT_ID"));
                dto.setR_title(rs.getString("R_TITLE"));
                dto.setR_content(rs.getString("R_CONTENT"));
                dto.setR_score(rs.getInt("R_SCORE"));
                dto.setR_img(rs.getString("R_IMG"));
                dto.setR_date(rs.getDate("R_DATE"));
                dto.setR_like(rs.getInt("R_LIKE"));

                images.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return images;
    }

    // ReviewDAO.java 맨 밑에 추가!
    public void getSortedReviewsAjax(HttpServletRequest request, HttpServletResponse response) {
        try {
            // 1. 응답 설정 (데이터 줄게! 한글 안 깨지게!)
            response.setContentType("application/json; charset=UTF-8");

            // 2. 파라미터 꺼내기 (컨테이너가 준 request에서 직접!)
            int pId = Integer.parseInt(request.getParameter("PRODUCT_ID"));
            String sortType = request.getParameter("sortType");
            String starFilterStr = request.getParameter("starFilter");
            int starFilter = (starFilterStr != null) ? Integer.parseInt(starFilterStr) : 0;

            // 3. 🌟 기존에 무영이가 만든 'getAllReview' 로직 재활용!
            // 이 메서드가 실행되면 가방(request)에 "reviews"라는 이름으로 리스트가 담겨!
            getAllReview(request, pId, sortType, starFilter);

            // 가방에서 다시 꺼내기
            ArrayList<ReviewDTO> reviews = (ArrayList<ReviewDTO>) request.getAttribute("reviews");

            // 4. 🌟 GSON으로 포장해서 바로 쏴버리기!
            Gson gson = new Gson();
            response.getWriter().write(gson.toJson(reviews));

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 🌟 [수정] 컨트롤러의 일(파라미터 빼기)까지 다 뺏어온 완벽한 DAO 메서드!
    public int toggleReviewLike(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int currentLikes = 0;

        try {
            // 1️⃣ 🌟 컨트롤러 대신 여기서 파라미터 언박싱!
            int reviewId = Integer.parseInt(request.getParameter("review_id"));
            String userId = request.getParameter("user_id"); // 나중엔 세션에서 꺼낼 예정!

            con = DBManager_new.connect();
            con.setAutoCommit(false); // 트랜잭션 시작

            // 2️⃣ 이 사람이 이 리뷰에 좋아요를 누른 적이 있는지 장부 검사!
            String checkSql = "SELECT COUNT(*) FROM review_likes WHERE review_id = ? AND user_id = ?";
            pstmt = con.prepareStatement(checkSql);
            pstmt.setInt(1, reviewId);
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();

            boolean alreadyLiked = false;
            if (rs.next() && rs.getInt(1) > 0) {
                alreadyLiked = true;
            }
            pstmt.close();

            // 3️⃣ 토글 분기 처리 (코드 동일)
            if (alreadyLiked) {
                // [좋아요 취소]
                String delSql = "DELETE FROM review_likes WHERE review_id = ? AND user_id = ?";
                pstmt = con.prepareStatement(delSql);
                pstmt.setInt(1, reviewId);
                pstmt.setString(2, userId);
                pstmt.executeUpdate();
                pstmt.close();

                String updateSql = "UPDATE reviews SET r_like = r_like - 1 WHERE review_id = ?";
                pstmt = con.prepareStatement(updateSql);
                pstmt.setInt(1, reviewId);
                pstmt.executeUpdate();
            } else {
                // [좋아요 추가]
                String insSql = "INSERT INTO review_likes (reviewlike_id, review_id, user_id) VALUES (review_likes_seq.NEXTVAL, ?, ?)";
                pstmt = con.prepareStatement(insSql);
                pstmt.setInt(1, reviewId);
                pstmt.setString(2, userId);
                pstmt.executeUpdate();
                pstmt.close();

                String updateSql = "UPDATE reviews SET r_like = r_like + 1 WHERE review_id = ?";
                pstmt = con.prepareStatement(updateSql);
                pstmt.setInt(1, reviewId);
                pstmt.executeUpdate();
            }
            pstmt.close();

            // 4️⃣ 최종 좋아요 개수 조회
            String countSql = "SELECT r_like FROM reviews WHERE review_id = ?";
            pstmt = con.prepareStatement(countSql);
            pstmt.setInt(1, reviewId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                currentLikes = rs.getInt("r_like");
            }

            con.commit(); // DB 확정!

        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            System.out.println("❌ 좋아요 처리 중 에러 발생!");
        } finally {
            try { if (con != null) con.setAutoCommit(true); } catch (Exception ex) {}
            DBManager_new.close(con, pstmt, rs);
        }

        return currentLikes; // 최종 개수 반환
    }

    // ==========================================
    // 🗑️ 리뷰 삭제 (관련 좋아요 데이터까지 싹 지우기)
    // ==========================================
    public boolean deleteReview(int reviewId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean success = false;

        try {
            con = DBManager_new.connect();
            con.setAutoCommit(false); // 🌟 트랜잭션 시작 (부분 실패 방지!)

            // 1. 좋아요 기록(자식) 먼저 삭제! (외래키 제약조건 때문)
            String sql1 = "DELETE FROM review_likes WHERE review_id = ?";
            pstmt = con.prepareStatement(sql1);
            pstmt.setInt(1, reviewId);
            pstmt.executeUpdate();
            pstmt.close();

            // 2. 진짜 리뷰(부모) 삭제!
            String sql2 = "DELETE FROM reviews WHERE review_id = ?";
            pstmt = con.prepareStatement(sql2);
            pstmt.setInt(1, reviewId);

            if (pstmt.executeUpdate() == 1) {
                success = true;
                con.commit(); // 🌟 둘 다 문제없이 지워졌으면 DB에 확정(도장 쾅)!
            }
        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {} // 에러 나면 롤백!
            e.printStackTrace();
            System.out.println("❌ 리뷰 삭제 중 에러 발생!");
        } finally {
            try { if (con != null) con.setAutoCommit(true); } catch (Exception ex) {}
            DBManager_new.close(con, pstmt, null);
        }
        return success;
    }

    // ==========================================
    // 🪄 리뷰 수정 (모든 계산 로직은 여기서 처리!)
    // ==========================================
    public boolean updateReview(HttpServletRequest request) {
        Connection con = null;
        PreparedStatement pstmt = null;

        try {
            // 1. 사진 저장 경로 잡기 및 MultipartRequest 생성 (언박싱 시작)
            String path = request.getServletContext().getRealPath("upload");
            MultipartRequest mr = new MultipartRequest(request, path, 10 * 1024 * 1024, "utf-8", new DefaultFileRenamePolicy());

            // 2. 파라미터 꺼내기
            int r_id = Integer.parseInt(mr.getParameter("upd_review_id"));
            String title = mr.getParameter("upd_title");
            String content = mr.getParameter("upd_content");
            int score = Integer.parseInt(mr.getParameter("upd_score"));

            String newImg = mr.getFilesystemName("upd_file");   // 새로 올린 사진 이름
            String oldImg = mr.getParameter("old_img_name");   // 기존 사진 이름
            String isImgDeleted = mr.getParameter("isImgDeleted"); // 삭제 여부(true/false)

            // 3. [계산 로직] 최종적으로 DB에 넣을 이미지 이름 결정하기
            String finalImg = oldImg; // 기본은 기존 사진 유지

            if (newImg != null) {
                // 상황 A: 새 사진을 올린 경우 (기존 사진 있으면 서버에서 삭제)
                finalImg = newImg;
                if (oldImg != null && !oldImg.isEmpty()) {
                    File f = new File(path + "/" + oldImg);
                    if (f.exists()) f.delete();
                }
            } else if ("true".equals(isImgDeleted)) {
                // 상황 B: 삭제 버튼(X)을 눌러서 이미지를 없앤 경우 (서버에서 파일도 삭제)
                finalImg = null;
                if (oldImg != null && !oldImg.isEmpty()) {
                    File f = new File(path + "/" + oldImg);
                    if (f.exists()) f.delete();
                }
            }

            // 4. 줄바꿈 처리 (엔터 친 거 화면에서 인식되게)
            content = content.replaceAll("\r\n", "<br>");

            // 5. DB 업데이트 실행
            con = DBManager_new.connect();
            String sql = "UPDATE reviews SET r_title=?, r_content=?, r_score=?, r_img=? WHERE review_id=?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setInt(3, score);
            pstmt.setString(4, finalImg);
            pstmt.setInt(5, r_id);

            // 6. 🌟 컨트롤러가 redirect할 때 써야 하니까 상품 ID 가방(request)에 다시 담아주기!
            request.setAttribute("PRODUCT_ID", mr.getParameter("PRODUCT_ID"));

            return pstmt.executeUpdate() == 1;

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("❌ 리뷰 수정 중 에러 발생!");
            return false;
        } finally {
            DBManager_new.close(con, pstmt, null);
        }
    }
} // ReviewDAO 클래스 끝