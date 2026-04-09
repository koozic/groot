package com.groot.app.supplements;

// DAO 역할 : DB에 접속해서 전체 영양성분 리스트를 조회(SELECT)한 뒤,
// 여러 개의 SupplementDTO를 리스트(List)에 담아 반환하는 역할

import com.groot.app.main.DBManager_new;
import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SupplementsDAO {
    // 싱글톤 패턴: 오직 하나의 객체만 생성하여 SDAO라는 이름으로 공유
    public static final SupplementsDAO SDAO = new SupplementsDAO();

    public SupplementsDAO() {
        // 기본 생성자
    }

        // 영양성분 전체 리스트 조회 메서드 (Read)
        public List<SupplementsDTO> getSupplementsList() {
            List<SupplementsDTO> SupplementList = new ArrayList<>();

            // SQL 테이블명과 컬럼명에 맞게 쿼리 수정 (최신순 정렬)
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
                    dto.setSupplementId(rs.getInt("supplement_id"));
                    dto.setSupplementName(rs.getString("supplement_name"));
                    dto.setSupplementEfficacy(rs.getString("supplement_efficacy"));
                    dto.setSupplementDosage(rs.getString("SUPPLEMENT_DOSAGE"));
                    dto.setSupplementTiming(rs.getString("SUPPLEMENT_TIMING"));
                    dto.setSupplementCaution(rs.getString("SUPPLEMENT_CAUTION"));
                    dto.setSupplementImagePath(rs.getString("supplement_image_path"));

                    // 데이터가 담긴 DTO를 List에 추가
                    SupplementList.add(dto);
                }
                System.out.println(SupplementList);

            } catch (Exception e) {
                e.printStackTrace();

            } finally {
                DBManager_new.close(con, pstmt, rs);
            }

            return SupplementList;
        }

        public void addSupplement (HttpServletRequest request){
            // 값 받거나 DB 세팅
            Connection con = null;
            PreparedStatement pstmt = null;

            // DB 컬럼보고 이름 적기!! (안전을 위해 추가할 컬럼명을 명시했습니다)
            String sql = "insert into supplements (supplement_id, supplement_name, supplement_efficacy, supplement_dosage, supplement_timing, supplement_caution,  supplement_image_path) " +
                    "values(seq_supplements_id.nextval,?,?,?,?,?,?)";
            SupplementsDTO dto = null;

            // 웹앱의 영양성분 파일 폴더
//            String path = "C:\\es\\dbws_intellij\\upload\\supplementFile";
            // 내 프로젝트 폴더 안의 /img/supp 위치를 컴퓨터가 알아서 찾아냅니다.
            String path = request.getServletContext().getRealPath("/supplementImg/supplementImgFile");

            try {
                con = DBManager_new.connect();
                pstmt = con.prepareStatement(sql);

                MultipartRequest mr = new MultipartRequest(request, path,
                        1024 * 1024 * 20, "UTF-8", new DefaultFileRenamePolicy());

                // jsp 인풋 파라미터 이름!
                String supplementName = mr.getParameter("supplementName");
                String supplementEfficacy = mr.getParameter("supplementEfficacy");
                String supplementDosage = mr.getParameter("supplementDosage");
                String supplementTiming = mr.getParameter("supplementTiming");
                String supplementCaution = mr.getParameter("supplementCaution");
                String supplementFile = mr.getFilesystemName("supplementFile");

                System.out.println(supplementName);
                System.out.println(supplementEfficacy);
                System.out.println(supplementDosage);
                System.out.println(supplementTiming);
                System.out.println(supplementCaution);
                System.out.println(supplementFile);

                if (supplementEfficacy != null) {
                    supplementEfficacy = supplementEfficacy.replace("\r\n", "<br>");
                }

                pstmt.setString(1, supplementName);
                pstmt.setString(2, supplementEfficacy);
                pstmt.setString(3, supplementDosage);
                pstmt.setString(4, supplementTiming);
                pstmt.setString(5, supplementCaution);

                // 순수한 파일명만 DB에 저장합니다!
                if (supplementFile == null) {
                    // 사진을 첨부하지 않은 경우 기본 이미지 파일명만 넣습니다.
                    pstmt.setString(6, "default.png");
                } else {
                    // 사진을 첨부한 경우 순수 파일명 저장
                    pstmt.setString(6, supplementFile);
                }

                if (pstmt.executeUpdate() == 1) {
                    System.out.println("add success");
                }

            } catch (Exception e) {
                e.printStackTrace();

            } finally {
                DBManager_new.close(con, pstmt, null);
            }
        }

        public void delSupplement (HttpServletRequest request){
            Connection con = null;
            PreparedStatement pstmt = null;

            try {
                con = DBManager_new.connect();

                String sql = "delete from supplements where supplement_id = ?";

                pstmt = con.prepareStatement(sql);

                // 값 세팅: JSP의 자바스크립트가 보낸 'id' 값을 가져옵니다.
                // deleteSupp.do?id=123 이므로 getParameter("id")라고 적어야 합니다!
                String id = request.getParameter("id");
                pstmt.setString(1, id);

                if (pstmt.executeUpdate() == 1) {
                    System.out.println("delete success (ID: " + id + ")");
                }

            } catch (Exception e) {
                e.printStackTrace();
                System.out.println("삭제 실패... 에러 발생!");
            } finally {
                DBManager_new.close(con, pstmt, null);
            }
        }

        // 영양성분 상세 조회
        public void getSupplementDetail (HttpServletRequest request){
//            핵심은 request.getParameter("id")로 전달된 고유 번호를 읽어서,
//            DB의 **supplement_id**와 매칭해 데이터를 한 줄 긁어오는 것

            Connection con = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            // 1. SQL 작성: ID 하나만 콕 집어서 가져옵니다.
            String sql = "SELECT * FROM supplements WHERE supplement_id = ?";

            try {
                con = DBManager_new.connect();
                pstmt = con.prepareStatement(sql);

                // 2. 값 세팅: JSP에서 ?id=... 로 보낸 값을 읽어옵니다.
                String id = request.getParameter("id");
                pstmt.setString(1, id);

                rs = pstmt.executeQuery();

                if (rs.next()) {
                    // 3. 데이터를 담을 DTO 객체 생성
                    SupplementsDTO dto = new SupplementsDTO();

                    dto.setSupplementId(rs.getInt("supplement_id"));
                    dto.setSupplementName(rs.getString("supplement_name"));
                    dto.setSupplementEfficacy(rs.getString("supplement_efficacy"));
                    dto.setSupplementDosage(rs.getString("supplement_dosage"));
                    dto.setSupplementTiming(rs.getString("supplement_timing"));
                    dto.setSupplementCaution(rs.getString("supplement_caution"));
                    dto.setSupplementImagePath(rs.getString("supplement_image_path"));

                    // 4. [중요] JSP에서 쓸 수 있도록 "detailSupp"라는 이름으로 담아줍니다.
                    request.setAttribute("detailSupp", dto);

                    // 확인용 출력
                    System.out.println("상세 조회 성공: " + dto.getSupplementName());
                }

            } catch (Exception e) {
                e.printStackTrace();
                System.out.println("상세 조회 중 에러 발생!");
            } finally {
                DBManager_new.close(con, pstmt, rs);
            }
        }

        // ==========================================================
        // 영양성분 수정하기 (Update)
        // ==========================================================
        public void updateSupplement (HttpServletRequest request){
            Connection con = null;
            PreparedStatement pstmt = null;

            // 1. 사진이 저장될 내 프로젝트 안의 진짜 폴더 경로 찾기
            String path = request.getServletContext().getRealPath("/supplementImg/supplementImgFile");

            String sql = "update supplements set supplement_name = ?, supplement_efficacy = ?, " +
                         "supplement_dosage = ?, supplement_timing = ?, supplement_caution = ?, " +
                         "supplement_image_path = ? WHERE supplement_id = ?";

            try {
                con = DBManager_new.connect();
                pstmt = con.prepareStatement(sql);

                // 폼에 첨부파일(enctype="multipart/form-data")이 있으니 무조건 MultipartRequest를 씁니다.
                //이제는 바로 가져오는것이 가능하니 mr필요없음 여기서는
                //  MultipartRequest mr = new MultipartRequest(request, path,
                //        1024 * 1024 * 20, "UTF-8", new DefaultFileRenamePolicy());

                // JSP에서 보낸 텍스트 데이터들 낚아채기
                String supplementId = request.getParameter("supplementId"); // 🚨 hidden으로 숨겨왔던 고유번호!
                String supplementName = request.getParameter("supplementName");
                String supplementEfficacy =request.getParameter("supplementEfficacy");
                String supplementDosage = request.getParameter("supplementDosage");
                String supplementTiming = request.getParameter("supplementTiming");
                String supplementCaution = request.getParameter("supplementCaution");

                // 줄바꿈(<br>) 처리
                if (supplementEfficacy != null) {
                    supplementEfficacy = supplementEfficacy.replace("\r\n", "<br>");
                }

                // 4. [핵심] 사진 처리 로직
                String oldFile = request.getParameter("oldSupplementFile");   // 🚨 hidden으로 숨겨왔던 기존 사진
                String newImageUrl = (String) request.getAttribute("newImageUrl"); // 이번에 새로 선택한 사진

                String updateFile; // 최종적으로 DB에 업데이트될 사진 이름

                if (newImageUrl == null) {
                    // 사용자가 [파일 선택]을 안 누르고 그냥 글씨만 고쳤다면? -> 기존 사진 유지!
                    updateFile = oldFile;
                } else {
                    // 새로운 사진을 올렸다면? -> 새로 올린 사진 이름으로 덮어쓰기!
                    updateFile = newImageUrl;
                }

                // 쿼리 준비 및 물음표(?) 세팅
                pstmt.setString(1, supplementName);
                pstmt.setString(2, supplementEfficacy);
                pstmt.setString(3, supplementDosage);
                pstmt.setString(4, supplementTiming);
                pstmt.setString(5, supplementCaution);
                pstmt.setString(6, updateFile); // 방금 위에서 결정한 사진 이름
                pstmt.setString(7, supplementId);         // WHERE 절의 조건(고유번호)

                // 진짜 실행
                if(pstmt.executeUpdate() == 1) {
                    System.out.println("update success");
                }

            } catch (Exception e) {

            } finally {
                DBManager_new.close(con, pstmt, null);
            }
        }

    // ==========================================================
    // 페이징 처리 로직
    // ==========================================================
    public void paging(int pageNum, HttpServletRequest request, List<SupplementsDTO> allList) {

        request.setAttribute("currentPage", pageNum);

        int total = allList.size(); // DB에서 가져온 전체 영양성분 개수
        int cnt = 6; // 💡 한 페이지당 보여줄 영양성분 개수 (원하는 대로 수정하세요! 예: 6개, 8개 등)

        // 1. 총 페이지 수 계산
        int totalPage = (int) Math.ceil((double) total / cnt);
        request.setAttribute("totalPage", totalPage);

        // 2. 역순 출력을 위한 인덱스 계산 (최신 등록된 것이 먼저 나오도록)
        int start = total - (cnt * (pageNum - 1));
        int end = (pageNum == totalPage) ? -1 : start - (cnt + 1);

        // 3. 계산된 인덱스만큼 전체 리스트에서 잘라내어 새 바구니(items)에 담기
        List<SupplementsDTO> items = new ArrayList<>();

        for (int i = start - 1; i > end; i--) {
            // IndexOutOfBounds 에러 방지를 위한 안전 장치
            if (i >= 0 && i < total) {
                items.add(allList.get(i));
            }
        }

        // 4. 잘라낸 리스트를 화면에 보내기 위해 세팅
        // (원래 Controller에서 하던 request.setAttribute를 덮어씁니다!)
        request.setAttribute("supplementsList", items);
    }

    // 좋아요 토글 (없으면 INSERT, 있으면 DELETE)
// 반환값: "liked" 또는 "unliked"
    public String supplementLike(String userId, int supplementId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String result = "unliked";

        try {
            con = DBManager_new.connect();

            // 이미 좋아요 눌렀는지 확인
            String checkSql = "SELECT COUNT(*) FROM supplements_like " +
                    "WHERE user_id = ? AND supplement_id = ?";
            pstmt = con.prepareStatement(checkSql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, supplementId);
            rs = pstmt.executeQuery();

            rs.next();
            int count = rs.getInt(1);
            DBManager_new.close(null, pstmt, rs);
            rs = null;

            if (count > 0) {
                // 이미 좋아요 → 취소(DELETE)
                String delSql = "DELETE FROM supplements_like " +
                        "WHERE user_id = ? AND supplement_id = ?";
                pstmt = con.prepareStatement(delSql);
                pstmt.setString(1, userId);
                pstmt.setInt(2, supplementId);
                pstmt.executeUpdate();
                result = "unliked";
            } else {
                // 좋아요 없음 → 추가(INSERT)
                String insSql = "INSERT INTO supplements_like " +
                        "(supplement_like_id, user_id, supplement_id) " +
                        "VALUES (seq_supplements_like_id.NEXTVAL, ?, ?)";
                pstmt = con.prepareStatement(insSql);
                pstmt.setString(1, userId);
                pstmt.setInt(2, supplementId);
                pstmt.executeUpdate();
                result = "liked";
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return result;
    }

    // 특정 유저가 좋아요 누른 supplementId 목록 조회
    public List<Integer> getLikedIdsByUser(String userId) {
        List<Integer> likedIds = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = DBManager_new.connect();
            String sql = "SELECT supplement_id FROM supplements_like WHERE user_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                likedIds.add(rs.getInt("supplement_id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return likedIds;
    }

    // 좋아요 토글 (없으면 INSERT, 있으면 DELETE)
// 반환값: "liked" 또는 "unliked"
    public String toggleLike(String userId, int supplementId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String result = "unliked";

        try {
            con = DBManager_new.connect();

            // 이미 좋아요 눌렀는지 확인
            String checkSql = "SELECT COUNT(*) FROM supplements_like " +
                    "WHERE user_id = ? AND supplement_id = ?";
            pstmt = con.prepareStatement(checkSql);
            pstmt.setString(1, userId);
            pstmt.setInt(2, supplementId);
            rs = pstmt.executeQuery();

            rs.next();
            int count = rs.getInt(1);
            DBManager_new.close(null, pstmt, rs);
            rs = null;

            if (count > 0) {
                // 이미 좋아요 → 취소(DELETE)
                String delSql = "DELETE FROM supplements_like " +
                        "WHERE user_id = ? AND supplement_id = ?";
                pstmt = con.prepareStatement(delSql);
                pstmt.setString(1, userId);
                pstmt.setInt(2, supplementId);
                pstmt.executeUpdate();
                result = "unliked";
            } else {
                // 좋아요 없음 → 추가(INSERT)
                String insSql = "INSERT INTO supplements_like " +
                        "(supplement_like_id, user_id, supplement_id) " +
                        "VALUES (seq_supplements_like_id.NEXTVAL, ?, ?)";
                pstmt = con.prepareStatement(insSql);
                pstmt.setString(1, userId);
                pstmt.setInt(2, supplementId);
                pstmt.executeUpdate();
                result = "liked";
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
        return result;
    }

    // 특정 유저가 좋아요 누른 supplementId 목록 조회
//    public List<Integer> getLikedIdsByUser(String userId) {
//        List<Integer> likedIds = new ArrayList<>();
//        Connection con = null;
//        PreparedStatement pstmt = null;
//        ResultSet rs = null;
//
//        try {
//            con = DBManager_new.connect();
//            String sql = "SELECT supplement_id FROM supplements_like WHERE user_id = ?";
//            pstmt = con.prepareStatement(sql);
//            pstmt.setString(1, userId);
//            rs = pstmt.executeQuery();
//            while (rs.next()) {
//                likedIds.add(rs.getInt("supplement_id"));
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        } finally {
//            DBManager_new.close(con, pstmt, rs);
//        }
//        return likedIds;
//    }
//
    }





