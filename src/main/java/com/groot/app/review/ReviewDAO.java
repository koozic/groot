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
            sql += " AND R_IMG IS NOT NULL ORDER BY R_DATE DESC";

        } else if ("high_score".equals(sortType)) {
            sql += " ORDER BY R_SCORE DESC, R_DATE DESC"; // 평점 높은순

        } else if ("low_score".equals(sortType)) {
            sql += " ORDER BY R_SCORE ASC, R_DATE DESC";  // 평점 낮은순

            // 🌟 [여기 추가!!!] '최신순'을 명확하게 알려주는 로직 추가! (번호가 높을수록 최근에 쓴 글)
        } else if ("date".equals(sortType)) {
            sql += " ORDER BY REVIEW_ID DESC";

        } else {
            // 아무것도 안 넘어오면 기본값은 좋아요순
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
            // ❌ 기존에 쓰던 골치 아픈 MultipartRequest(mr) 완전 삭제!
            // ✅ 대신 일반 request.getParameter()를 다시 씁니다.
            String product_id = request.getParameter("product_id");
            String r_title = request.getParameter("r_title");
            String r_score = request.getParameter("r_score");
            String r_content = request.getParameter("r_content");

            // 🌟 [핵심 변경] 사진을 클라우드에 올리고 인터넷 주소(URL)만 받아옵니다!
            // 파라미터: 1. request, 2. input태그 name("r_img"), 3. 저장할 폴더명("review")
            String r_img_url = com.groot.app.common.CloudinaryUtil.uploadFromRequest(request, "r_img", "review");

            // 세션에서 아이디 꺼내기
            com.groot.app.user.UserDTO loginUser = (com.groot.app.user.UserDTO) request.getSession().getAttribute("loginUser");
            String user_id = loginUser.getUser_id();

            // ==========================================
            // [보안 및 필터링 구간] - 기존과 동일
            r_title = r_title.replace("<", "&lt;").replace(">", "&gt;");
            r_content = r_content.replace("<", "&lt;").replace(">", "&gt;");
            String[] badWords = {"시발","씨발", "존나", "개새끼", "ㅅㅂ"};
            for (String word : badWords) {
                r_title = r_title.replaceAll(word, "꿍디");
                r_content = r_content.replaceAll(word, "꿍디");
            }
            r_content = r_content.replaceAll("\r\n", "<br>");
            // ==========================================

            request.setAttribute("p_id", product_id);

            // DB 연결 및 INSERT
            con = DBManager_new.connect();
            String sql = "INSERT INTO reviews (review_id, user_id, product_id, r_title, r_content, r_score, r_img, r_date, r_like) " +
                    "VALUES (reviews_seq.NEXTVAL, ?, ?, ?, ?, ?, ?, SYSDATE, 0)";

            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, user_id);
            pstmt.setInt(2, Integer.parseInt(product_id));
            pstmt.setString(3, r_title);
            pstmt.setString(4, r_content);
            pstmt.setInt(5, Integer.parseInt(r_score));

            // DB에는 클라우드에서 받은 긴 인터넷 주소를 넣습니다!
            pstmt.setString(6, r_img_url);

            if (pstmt.executeUpdate() == 1) {
                System.out.println("✅ 클라우드 사진 업로드 & 리뷰 작성 성공!");
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
// 🪄 리뷰 수정 (보안 필터 및 이미지 로직 통합!)
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

            // ------------------------------------------
            // 🌟 [보안 및 필터링 구간] - 여기서 싹 세탁합니다!
            // ------------------------------------------

            // ① XSS 방어 (스크립트 공격 무력화)
            title = title.replace("<", "&lt;").replace(">", "&gt;");
            content = content.replace("<", "&lt;").replace(">", "&gt;");

            // ② 욕설 필터링 (비속어를 '꿍디'로!)
            String[] badWords = {"시발", "존나", "개새끼", "ㅅㅂ"};
            for (String word : badWords) {
                title = title.replaceAll(word, "꿍디");
                content = content.replaceAll(word, "꿍디");
            }

            // ③ 줄바꿈 처리 (모든 필터링 후에 <br>로 바꿔야 안전!)
            content = content.replaceAll("\r\n", "<br>");

            // ------------------------------------------

            // 3. [이미지 로직] 최종적으로 DB에 넣을 이미지 이름 결정하기
            String finalImg = oldImg; // 기본은 기존 사진 유지

            if (newImg != null) {
                // 상황 A: 새 사진을 올린 경우 (기존 사진 있으면 서버에서 삭제)
                finalImg = newImg;
                if (oldImg != null && !oldImg.isEmpty()) {
                    File f = new File(path + "/" + oldImg);
                    if (f.exists()) f.delete();
                }
            } else if ("true".equals(isImgDeleted)) {
                // 상황 B: 삭제 버튼(체크박스)을 눌러서 이미지를 없앤 경우
                finalImg = null;
                if (oldImg != null && !oldImg.isEmpty()) {
                    File f = new File(path + "/" + oldImg);
                    if (f.exists()) f.delete();
                }
            }

            // 4. DB 업데이트 실행
            con = DBManager_new.connect();
            String sql = "UPDATE reviews SET r_title=?, r_content=?, r_score=?, r_img=? WHERE review_id=?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setInt(3, score);
            pstmt.setString(4, finalImg);
            pstmt.setInt(5, r_id);

            // 5. 컨트롤러용 상품 ID 담기
            request.setAttribute("PRODUCT_ID", mr.getParameter("upd_p_id")); // JSP의 upd_p_id와 이름 맞춰주기!

            return pstmt.executeUpdate() == 1;

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("❌ 리뷰 수정 중 에러 발생!");
            return false;
        } finally {
            DBManager_new.close(con, pstmt, null);
        }
    }
    // =========================================================
    // 🏆 메인 페이지용 베스트 리뷰 4개 가져오기 (3단 조인 풀버전)
    // =========================================================
    public ArrayList<ReviewDTO> getBestReviews() {
        ArrayList<ReviewDTO> bestList = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBManager_new.connect();

            // 🌟 에이스 무영표 3단 조인 쿼리! (리뷰 + 제품 + 성분 + 해당 제품의 평균 평점까지)
            String sql =
                    "SELECT * FROM (" +
                            "    SELECT " +
                            "        R.review_id, R.user_id, R.product_id, R.r_title, R.r_content, " +
                            "        R.r_score, R.r_img, R.r_date, R.r_like, " +
                            "        P.product_name, P.product_image, " +
                            "        S.supplement_name, " +
                            "        (SELECT ROUND(NVL(AVG(r_score), 0), 1) FROM reviews WHERE product_id = P.product_id) AS avg_score " +
                            "    FROM reviews R " +
                            "  LEFT JOIN products P ON R.product_id = P.product_id " +
                            "  LEFT JOIN supplements S ON P.product_nutrient = S.supplement_id " +
                            "    ORDER BY R.r_like DESC, R.r_date DESC" +
                            ") WHERE ROWNUM <= 15";

            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ReviewDTO r = new ReviewDTO();
                // 1. 기존 리뷰 정보
                r.setReview_id(rs.getInt("review_id"));
                r.setUser_id(rs.getString("user_id"));
                r.setProduct_id(rs.getInt("product_id"));
                r.setR_title(rs.getString("r_title"));
                r.setR_content(rs.getString("r_content"));
                r.setR_score(rs.getInt("r_score"));
                r.setR_img(rs.getString("r_img"));
                r.setR_date(rs.getDate("r_date"));
                r.setR_like(rs.getInt("r_like"));

                // 2. 🌟 조인으로 가져온 제품 & 성분 정보 세팅!
                r.setP_name(rs.getString("product_name"));
                r.setP_img(rs.getString("product_image"));
                r.setSupp_name(rs.getString("supplement_name"));
                r.setP_avg_score(rs.getDouble("avg_score"));

                bestList.add(r);
            }
        } catch (Exception e) {
            System.out.println("❌ 베스트 리뷰 3단 조인 에러!");
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return bestList;
    }
    // ReviewDAO.java 안에 아래 메서드를 추가하세요!

    // 🌟 [추가 1] 내 영양제 분석용 (기존 로직 + 번역 기능 포함)
    public ArrayList<ReviewDTO> getCustomBestReviews(String[] rawSupps) {
        ArrayList<ReviewDTO> list = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBManager_new.connect();
            StringBuilder sql = new StringBuilder(
                    "SELECT * FROM (" +
                            "    SELECT R.*, P.product_name, S.supplement_name " +
                            "    FROM reviews R " +
                            "    JOIN products P ON R.product_id = P.product_id " +
                            "    JOIN supplements S ON P.product_nutrient = S.supplement_id "
            );

            if (rawSupps != null && rawSupps.length > 0) {
                sql.append(" WHERE S.supplement_name IN (");
                for (int i = 0; i < rawSupps.length; i++) {
                    sql.append("?");
                    if (i < rawSupps.length - 1) sql.append(", ");
                }
                sql.append(") ");
            }

            sql.append("    ORDER BY R.r_like DESC, R.r_date DESC " +
                    ") WHERE ROWNUM <= 3");

            pstmt = con.prepareStatement(sql.toString());

            // 🌟 DAO 안에서 통역하며 세팅!
            if (rawSupps != null && rawSupps.length > 0) {
                for (int i = 0; i < rawSupps.length; i++) {
                    pstmt.setString(i + 1, translateSupp(rawSupps[i])); // 번역기 호출
                }
            }

            rs = pstmt.executeQuery();
            while (rs.next()) {
                ReviewDTO r = new ReviewDTO();
                r.setR_score(rs.getInt("r_score"));
                r.setR_content(rs.getString("r_content"));
                r.setUser_id(rs.getString("user_id"));
                r.setSupp_name(rs.getString("supplement_name"));
                list.add(r);
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager_new.close(con, pstmt, rs); }
        return list;
    }

    // 🌟 [추가 2] 부족한 영양소 분석용 (분배 로직 + 번역 기능 포함)
    public ArrayList<ReviewDTO> getDeficiencyBestReviews(String[] rawSupps, int limitPerSupp) {
        ArrayList<ReviewDTO> list = new ArrayList<>();
        if (rawSupps == null || rawSupps.length == 0) return list;

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBManager_new.connect();
            String sql = "SELECT * FROM (" +
                    "    SELECT R.*, P.product_name, S.supplement_name " +
                    "    FROM reviews R " +
                    "    JOIN products P ON R.product_id = P.product_id " +
                    "    JOIN supplements S ON P.product_nutrient = S.supplement_id " +
                    "    WHERE S.supplement_name = ? " +
                    "    ORDER BY R.r_like DESC, R.r_date DESC " +
                    ") WHERE ROWNUM <= ?";

            pstmt = con.prepareStatement(sql);

            // 🌟 전달받은 영양제 각각에 대해 쿼리 실행
            for (String s : rawSupps) {
                pstmt.setString(1, translateSupp(s)); // 번역기 호출
                pstmt.setInt(2, limitPerSupp); // 할당된 개수만큼만!
                rs = pstmt.executeQuery();

                while (rs.next()) {
                    ReviewDTO r = new ReviewDTO();
                    r.setR_score(rs.getInt("r_score"));
                    r.setR_content(rs.getString("r_content"));
                    r.setUser_id(rs.getString("user_id"));
                    r.setSupp_name(rs.getString("supplement_name"));
                    list.add(r);
                }
                rs.close();
            }
        } catch (Exception e) { e.printStackTrace(); }
        finally { DBManager_new.close(con, pstmt, rs); }
        return list;
    }

    // 🌟 [추가 3] 영어를 한글로 바꿔주는 프라이빗 번역기!
    private String translateSupp(String eng) {
        switch(eng) {
            case "vitC": return "비타민 C";
            case "vitD": return "비타민 D";
            case "vitB": return "비타민 B";
            case "vitA": return "비타민 A";
            case "vitE": return "비타민 E";
            case "omega3": return "오메가3";
            case "magnesium": return "마그네슘";
            case "calcium": return "칼슘";
            case "iron": return "철분";
            case "zinc": return "아연";
            default: return eng;
        }
    }
    // 🌟 [라운지 필터 전용] 카테고리별 베스트 리뷰 가져오기
    public ArrayList<ReviewDTO> getLoungeFilterReviews(String category) {
        ArrayList<ReviewDTO> list = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBManager_new.connect();

            // 1. 기본 뼈대 (리뷰 + 상품명/사진 + 성분명 조인)
            String sql = "SELECT * FROM (" +
                    "    SELECT R.*, P.product_name, P.product_image, S.supplement_name " +
                    "    FROM reviews R " +
                    "    LEFT JOIN products P ON R.product_id = P.product_id " +
                    "    LEFT JOIN supplements S ON P.product_nutrient = S.supplement_id ";

            // 2. 동적 필터링 조건 추가!
            if ("photo".equals(category)) {
                // 포토 리뷰만 보기
                sql += " WHERE R.r_img IS NOT NULL ";
            } else if (!"all".equals(category)) {
                // 특정 성분(비타민 C 등)만 보기
                sql += " WHERE S.supplement_name = ? ";
            }

            // 3. 정렬 및 상위 20개 자르기
            sql += "    ORDER BY R.r_like DESC, R.r_date DESC " +
                    ") WHERE ROWNUM <= 20";

            pstmt = con.prepareStatement(sql);

            // 4. 물음표 세팅 ("all"이나 "photo"가 아닐 때만 성분명이 들어감)
            if (!"all".equals(category) && !"photo".equals(category)) {
                pstmt.setString(1, category);
            }

            rs = pstmt.executeQuery();

            while (rs.next()) {
                ReviewDTO r = new ReviewDTO();
                r.setReview_id(rs.getInt("review_id"));
                r.setUser_id(rs.getString("user_id"));
                r.setProduct_id(rs.getInt("product_id"));
                r.setR_title(rs.getString("r_title"));
                r.setR_content(rs.getString("r_content"));
                r.setR_score(rs.getInt("r_score"));
                r.setR_img(rs.getString("r_img"));
                r.setR_date(rs.getDate("r_date"));
                r.setR_like(rs.getInt("r_like"));

                // 조인된 데이터들
                r.setP_name(rs.getString("product_name"));
                r.setP_img(rs.getString("product_image"));
                r.setSupp_name(rs.getString("supplement_name"));

                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return list;
    }
} // ReviewDAO 클래스 끝