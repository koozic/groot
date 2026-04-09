package com.groot.app.mypage;

import com.groot.app.main.DBManager_new;
import com.groot.app.product.ProductDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class MyPageDAO {
    // 싱글톤 패턴 적용
    public static final MyPageDAO MDAO = new MyPageDAO();

    private MyPageDAO() {
    }

    /**
     * 특정 유저가 등록한 '내 영양제' 리스트 조회
     *
     * @param userId 세션에서 가져온 유저 ID
     * @return 유저가 등록한 ProductDTO 리스트
     */
    public ArrayList<ProductDTO> getUserProducts(String userId) {
        ArrayList<ProductDTO> myProducts = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // JOIN 쿼리: user_supplements 테이블과 products 테이블을 조인하여 해당 유저의 제품만 조회
        String sql = "SELECT p.* FROM products p " +
                "JOIN user_supplements us ON p.product_id = us.product_id " +
                "WHERE us.user_id = ?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                ProductDTO dto = new ProductDTO(
                        rs.getInt("product_id"),
                        rs.getString("product_admin"),
                        rs.getString("product_name"),
                        rs.getString("product_brand"),
                        rs.getInt("product_price"),
                        rs.getInt("product_nutrient"),
                        rs.getString("product_description"),
                        rs.getString("product_image"),
                        rs.getInt("product_total"),
                        rs.getInt("product_serve"),
                        rs.getInt("product_per_day"),
                        rs.getString("product_time_info"),
                        rs.getDate("product_start_date"),
                        rs.getInt("product_current")
                );
                myProducts.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }

        return myProducts;
    }


    public boolean addMyProduct(String userId, int productId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean isSuccess = false;

        // TODO: 테이블명이 다를 경우 수정하세요 (예: user_supplements)
        String sql = "INSERT INTO user_supplements (user_id, product_id) VALUES (?, ?)";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, productId);

            // INSERT 성공 시 1 반환
            if (pstmt.executeUpdate() == 1) {
                isSuccess = true;
            }
        } catch (java.sql.SQLIntegrityConstraintViolationException e) {
            // 이미 추가된 영양제일 경우 (중복 에러 방어)
            System.out.println("이미 등록된 영양제입니다.");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }

        return isSuccess;
    }

    public boolean removeMyProduct(String userId, int productId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean isSuccess = false;

        try {
            con = DBManager_new.connect();

            // 1. 해당 영양제의 모든 복용 기록(체크 내역)을 우선 삭제하여 상태 초기화
            String sql1 = "DELETE FROM user_intake_log WHERE user_id = ? AND product_id = ?";
            pstmt = con.prepareStatement(sql1);
            pstmt.setString(1, userId);
            pstmt.setInt(2, productId);
            pstmt.executeUpdate();
            pstmt.close(); // 첫 번째 작업 종료 후 닫기

            // 2. 내 영양제 매핑 테이블에서 제품 완전히 삭제
            String sql2 = "DELETE FROM user_supplements WHERE user_id = ? AND product_id = ?";
            pstmt = con.prepareStatement(sql2);
            pstmt.setString(1, userId);
            pstmt.setInt(2, productId);

            if (pstmt.executeUpdate() == 1) {
                isSuccess = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }

        return isSuccess;
    }

    // 1. 복용 여부 업데이트 (체크 시 INSERT, 해제 시 DELETE)
    public boolean updateIntakeStatus(String userId, int productId, boolean isTaken) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = isTaken
                ? "INSERT INTO user_intake_log (user_id, product_id, intake_date) VALUES (?, ?, SYSDATE)"
                : "DELETE FROM user_intake_log WHERE user_id = ? AND product_id = ? AND TRUNC(intake_date) = TRUNC(SYSDATE)";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, productId);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            DBManager_new.close(con, pstmt, null);
        }
    }

    // 2. 오늘 복용한 영양제 ID 리스트 조회 (화면 복구용)
    public ArrayList<Integer> getTodayIntakeList(String userId) {
        ArrayList<Integer> list = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT product_id FROM user_intake_log WHERE user_id = ? AND TRUNC(intake_date) = TRUNC(SYSDATE)";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("product_id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return list;
    }

    // 1. 구매 알림용 데이터 조회 로직 (Java 연산 처리)
    public ArrayList<Map<String, Object>> getAlertData(String userId) {
        ArrayList<Map<String, Object>> alertList = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // 단순 조인을 통해 제품 정보와 사용자의 총 복용 횟수(intake_count)만 조회
        String sql = "SELECT p.product_id, p.product_name, p.product_total, p.product_serve, p.product_per_day, " +
                "(SELECT COUNT(*) FROM user_intake_log l WHERE l.product_id = p.product_id AND l.user_id = ?) AS intake_count " +
                "FROM user_supplements us " +
                "JOIN products p ON us.product_id = p.product_id " +
                "WHERE us.user_id = ?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                String name = rs.getString("product_name");
                int total = rs.getInt("product_total");
                int serve = rs.getInt("product_serve");
                int perDay = rs.getInt("product_per_day");
                int intakeCount = rs.getInt("intake_count");

                // Java 단에서 잔여 일수 연산
                int dailyConsume = serve * perDay;
                int remainDays = 0;

                if (dailyConsume > 0) {
                    int remainPills = total - (intakeCount * dailyConsume);
                    remainDays = remainPills / dailyConsume;
                }

                Map<String, Object> map = new HashMap<>();
                map.put("productName", name);
                map.put("remainDays", remainDays);

                // 상태 조건 판별
                if (remainDays <= 5) map.put("status", "warn");
                else if (remainDays <= 10) map.put("status", "buy");
                else map.put("status", "ok");

                alertList.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return alertList;
    }

    // 2. 전체 복용 통계 조회 로직 (시작일 기준 누적 데이터)
    public Map<String, Object> getIntakeStatistics(String userId) {
        Map<String, Object> stats = new HashMap<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String sql = "SELECT p.product_start_date, " +
                "(SELECT COUNT(*) FROM user_intake_log l WHERE l.product_id = p.product_id AND l.user_id = ?) AS actual_intake " +
                "FROM user_supplements us " +
                "JOIN products p ON us.product_id = p.product_id " +
                "WHERE us.user_id = ?";

        int totalExpectedDays = 0;
        int totalActualIntake = 0;

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setString(2, userId);
            rs = pstmt.executeQuery();

            long currentTime = System.currentTimeMillis();

            while (rs.next()) {
                java.sql.Date startDate = rs.getDate("product_start_date");
                int actual = rs.getInt("actual_intake");

                int expected = 0;
                if (startDate != null) {
                    long diff = currentTime - startDate.getTime();
                    // 밀리초를 일(Day) 단위로 변환 (시작일 포함 +1)
                    expected = (int) (diff / (1000 * 60 * 60 * 24)) + 1;
                }

                totalExpectedDays += expected;
                totalActualIntake += actual;
            }

            // 전체 달성률(%) 계산
            int progressPercent = (totalExpectedDays > 0) ? (int) ((double) totalActualIntake / totalExpectedDays * 100) : 0;

            stats.put("totalExpected", totalExpectedDays);
            stats.put("totalActual", totalActualIntake);
            stats.put("progressPercent", progressPercent);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return stats;
    }

    /**
     * 특정 연/월의 복용 기록 일자(Day) 리스트 조회
     * 캘린더 데이터 바인딩용
     */
    public ArrayList<Integer> getMonthlyIntake(String userId, int year, int month) {
        ArrayList<Integer> days = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // Oracle 기준: 해당 연도와 월에 복용 기록이 있는 '일(Day)'만 중복 없이 추출
        String sql = "SELECT DISTINCT EXTRACT(DAY FROM intake_date) AS intake_day " +
                "FROM user_intake_log " +
                "WHERE user_id = ? " +
                "AND EXTRACT(YEAR FROM intake_date) = ? " +
                "AND EXTRACT(MONTH FROM intake_date) = ?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, year);
            pstmt.setInt(3, month);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                // 예: 1일, 5일, 12일에 복용했다면 [1, 5, 12] 형태로 리스트에 추가
                days.add(rs.getInt("intake_day"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return days;
    }

    public ArrayList<Map<String, Object>> getMonthlyIntakeStatistics(String userId, int currentYear, int currentMonth) {
        ArrayList<Map<String, Object>> statsList = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        // 특정 연/월에 해당하는 유저의 복용 기록을 제품별로 그룹화하여 카운트
        String sql = "SELECT p.product_name, COUNT(l.intake_date) AS intake_count " +
                "FROM user_supplements us " +
                "JOIN products p ON us.product_id = p.product_id " +
                "LEFT JOIN user_intake_log l ON us.user_id = l.user_id AND us.product_id = l.product_id " +
                "AND EXTRACT(YEAR FROM l.intake_date) = ? " +
                "AND EXTRACT(MONTH FROM l.intake_date) = ? " +
                "WHERE us.user_id = ? " +
                "GROUP BY p.product_id, p.product_name " +
                "ORDER BY intake_count DESC";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, currentYear);
            pstmt.setInt(2, currentMonth);
            pstmt.setString(3, userId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("productName", rs.getString("product_name"));
                map.put("intakeCount", rs.getInt("intake_count"));
                statsList.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return statsList;


    }

    public Map<Integer, String> getMonthlyIntakeStatus(String userId, int year, int month) {
        Map<Integer, String> statusMap = new HashMap<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBManager_new.connect();

            // 1. 유저가 현재 등록한 총 영양제 개수 파악
            int totalSupps = 0;
            String sqlTotal = "SELECT COUNT(*) FROM user_supplements WHERE user_id = ?";
            pstmt = con.prepareStatement(sqlTotal);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) totalSupps = rs.getInt(1);

            // Statement 닫고 다음 쿼리 준비
            pstmt.close();
            rs.close();

            if (totalSupps == 0) return statusMap; // 등록된 영양제가 없으면 빈 상태 반환

            // 2. 월별 각 일자(Day)에 복용한 영양제 개수 카운트
            String sqlCount = "SELECT EXTRACT(DAY FROM intake_date) AS d, COUNT(product_id) AS cnt " +
                    "FROM user_intake_log " +
                    "WHERE user_id = ? AND EXTRACT(YEAR FROM intake_date) = ? AND EXTRACT(MONTH FROM intake_date) = ? " +
                    "GROUP BY EXTRACT(DAY FROM intake_date)";

            pstmt = con.prepareStatement(sqlCount);
            pstmt.setString(1, userId);
            pstmt.setInt(2, year);
            pstmt.setInt(3, month);
            rs = pstmt.executeQuery();

            // 3. 총 개수와 복용 개수를 비교하여 상태 정의
            while (rs.next()) {
                int day = rs.getInt("d");
                int count = rs.getInt("cnt");

                if (count >= totalSupps) {
                    statusMap.put(day, "complete"); // 모두 복용 완료
                } else {
                    statusMap.put(day, "partial");  // 일부 누락
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return statusMap;
    }
}

