package com.groot.app.user;

import com.groot.app.common.CloudinaryUtil;
import com.groot.app.main.DBManager_new;
import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;
import lombok.NonNull;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {
    public static boolean Login(HttpServletRequest request) {
        String id = request.getParameter("user_id");
        String pw = request.getParameter("user_pw");

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;


        // 수정 1: 필요한 모든 유저 정보를 가져오기 위해 SELECT * 사용
        String sql = "SELECT * FROM users WHERE user_id=?";
        boolean isLoginSuccess = false; // 로그인 성공 여부 저장 변수


        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, id); // request.getParameter 대신 변수 id 사용
            rs = pstmt.executeQuery();
            String loginMsg = "";


            if (rs.next()) {
                if (rs.getString("user_pw").equals(pw)) {
                    // [일반 유저 로그인 성공]
                    UserDTO user = new UserDTO();
                    user.setUser_id(rs.getString("user_id"));
                    user.setName(rs.getString("user_name"));
                    user.setEmail(rs.getString("user_email"));
                    user.setAge(rs.getInt("user_age"));
                    user.setGender(rs.getString("user_gender"));
                    user.setUser_profile(rs.getString("user_profile"));

                    HttpSession session = request.getSession();
                    session.setAttribute("loginUser", user);
                    session.removeAttribute("isAdmin"); // 일반 유저이므로 관리자 권한 제거
                    session.removeAttribute("loginFailCount");

                    request.setAttribute("loginMsg", "어서오세요. 당신의 건강을 챙기세요");
                    isLoginSuccess = true;
                } else if (rs.getString("user_pw").equals("ADMIN_PROTECTED")) {
                    // ── Step 2. users에 없으면 admin 테이블 조회 ──
                    // 중요: 다음 조회를 위해 기존 리소스 닫기
                    DBManager_new.close(null, pstmt, rs);

                    String adminSql = "SELECT * FROM admin WHERE admin_id=?";
                    pstmt = con.prepareStatement(adminSql);
                    pstmt.setString(1, id);
                    rs = pstmt.executeQuery();

                    if (rs.next()) {
                        if (rs.getString("admin_pw").equals(pw)) {
                            // [관리자 로그인 성공]
                            UserDTO adminUser = new UserDTO();
                            adminUser.setUser_id(rs.getString("admin_id"));
                            adminUser.setName(rs.getString("admin_name"));
                            adminUser.setEmail(rs.getString("admin_email"));
                            // 관리자는 프로필 이미지가 없을 수 있으므로 기본값 설정 가능
                            adminUser.setUser_profile("admin_icon.png");

                            // 2. 중요: users 테이블에 이 관리자 ID가 있는지 확인하고, 없으면 생성
                            // 이 처리를 통해 supplements_like 테이블의 FK 제약조건을 통과할 수 있습니다.
                            try {
                                syncAdminToUserTable(adminUser);

                            } catch (Exception e) {
                                System.out.println("⚠️ 동기화 중 오류가 났지만 로그인은 진행합니다: " + e.getMessage());
                            }

                            HttpSession session = request.getSession();
                            session.setAttribute("loginUser", adminUser);
                            session.setAttribute("isAdmin", true); // 관리자 권한 부여
                            session.removeAttribute("loginFailCount");

                            request.setAttribute("loginMsg", "관리자로 로그인되었습니다.");
                            isLoginSuccess = true;
                        } else {
                            // 관리자 비밀번호 불일치
                            incrementFailCount(request, id);
                            request.setAttribute("loginMsg", "아이디 또는 비밀번호가 일치하지 않습니다.");
                        }
                    } else {
                        // 유저도 아니고 관리자도 아닌 경우
                        incrementFailCount(request, id);
                        request.setAttribute("loginMsg", "존재하지 않는 아이디입니다. 회원가입 해주세요");
                        request.setAttribute("needVerifyChoice", true);
                    }
                } else {


                    // 비밀번호 불일치
                    incrementFailCount(request, id);
                    request.setAttribute("loginMsg", "아이디 또는 비밀번호가 일치하지 않습니다.");
                }
            }


        } catch (Exception e) {
            e.printStackTrace();


        } finally {
            DBManager_new.close(con, pstmt, rs);
        }

        // 컨트롤러에게 로그인 성공 여부를 반환
        return isLoginSuccess;
    }

    private static void syncAdminToUserTable(UserDTO adminUser) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String checkSql = "SELECT user_id FROM users WHERE user_id = ?";

        // 컬럼명을 명시하여 순서 꼬임을 방지합니다.
        String insertSql = "INSERT INTO users (user_id, user_pw, user_name, user_age, user_gender, user_profile, user_email, user_address, user_agree, user_join_path, user_point, user_grade) " +
                "VALUES (?, 'ADMIN_PROTECTED', ?, 0, 'N', ?, ?, 'ADMIN_ADDR', 'Y', 'ADMIN', '0', 'A')";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(checkSql);
            pstmt.setString(1, adminUser.getUser_id());
            rs = pstmt.executeQuery();

            if (!rs.next()) {
                DBManager_new.close(null, pstmt, rs);

                pstmt = con.prepareStatement(insertSql);
                // 명시한 컬럼 순서대로 매핑
                pstmt.setString(1, adminUser.getUser_id());      // user_id
                pstmt.setString(2, adminUser.getName());         // user_name
                pstmt.setString(3, "admin_icon.png");           // user_profile
                pstmt.setString(4, adminUser.getEmail());        // user_email

                pstmt.executeUpdate();
                System.out.println("✅ 관리자 동기화 성공: " + adminUser.getUser_id());
            }
        } catch (Exception e) {
            System.out.println("❌ 동기화 실패: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }
    }

    private static void incrementFailCount(HttpServletRequest request, String id) {
        Integer failCount = (Integer) request.getSession().getAttribute("loginFailCount");
        if (failCount == null) {
            failCount = 1;
        } else {
            failCount++;
        }

        request.getSession().setAttribute("loginFailCount", failCount);

        // 5회 실패 시 리디렉션을 위한 플래그 설정
        if (failCount >= 5) {
            request.setAttribute("redirectJoin", true);
        }
    }

    public static boolean LoginCheck(HttpServletRequest req) {
        UserDTO check = (UserDTO) req.getSession().getAttribute("check");

        if (check != null) {
            req.setAttribute("loginPage", "user/loginOK.jsp");
            return true;
        } else {
            req.setAttribute("loginPage", "user/login.jsp");
            return false;
        }


    }

    public static void ProfileUpdate(@NonNull HttpServletRequest request) {

        UserDTO loginUser = (UserDTO) request.getSession().getAttribute("loginUser");
        String newProfile = request.getParameter("user_profile");

        Connection con = null;
        PreparedStatement pstmt = null;

        String sql = "update users set user_profile = ? where user_id = ?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, loginUser.getUser_profile());
            pstmt.setString(2, loginUser.getUser_id());

            int result = pstmt.executeUpdate();

            if (result == 1) {
                loginUser.setUser_profile(newProfile);
                request.getSession().setAttribute("loginUser", loginUser);
                request.setAttribute("msg", "프로필 이미지가 수정되었습니다.");
            } else {
                request.setAttribute("msg", "프로필 이미지 수정 실패");
            }

            loginUser.setUser_profile(newProfile);
            request.getSession().setAttribute("loginUser", loginUser);


        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("msg", "프로필 이미지 수정 중 오류가 발생했습니다.");
        } finally {
            DBManager_new.close(con, pstmt, null);
        }
    }


    public static void join(HttpServletRequest request) {

        Connection con = null;
        PreparedStatement pstmt = null;

        String sql = "insert into users values (?,?,?,?,?,?,?,?,?,?,?,?)";

        try {

            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);

            pstmt.setString(1, request.getParameter("user_id"));
            pstmt.setString(2, request.getParameter("user_pw"));
            pstmt.setString(3, request.getParameter("user_name"));
            pstmt.setInt(4, Integer.parseInt(request.getParameter("user_age")));
            pstmt.setString(5, request.getParameter("user_gender"));

            // =========================
            // 프로필 이미지 처리
            // =========================


            String selectedProfile = request.getParameter("default_profile");   // 라디오 선택값

            String uploadedProfile = (String) request.getAttribute("user_profile"); // UserJoinC에서 업로드한 URL
            String finalProfilePath="";

            // UserJoinC에서 Cloudinary 업로드한 URL이 있으면 우선 사용
            if (uploadedProfile != null && !uploadedProfile.trim().isEmpty()) {
                finalProfilePath = uploadedProfile;
                System.out.println("Cloudinary 업로드 이미지: " + finalProfilePath);

            }
            else if (selectedProfile != null && !selectedProfile.trim().isEmpty()) {

                finalProfilePath = "user/userImg/" + selectedProfile;
                System.out.println("기본 프로필 선택: " + finalProfilePath);
            }
            // 혹시 모를 예외 대비
            else {
                finalProfilePath = "user/userImg/Ayanokoji.jpg";
                System.out.println("기본값 적용: " + finalProfilePath);
            }

            // DB에는 문자열 경로 저장
            pstmt.setString(6, finalProfilePath);

            pstmt.setString(7, request.getParameter("user_email"));

            // =========================
            // 주소 합치기
            // =========================
            String zipcode = request.getParameter("user_zipcode");
            String roadAddr = request.getParameter("user_road_address");
            String detailAddr = request.getParameter("user_detail_address");
            String extraAddr = request.getParameter("user_extra_address");

            String fullAddress = "";

            if (zipcode != null && !zipcode.trim().isEmpty()) {
                fullAddress += "[" + zipcode + "] ";
            }
            if (roadAddr != null && !roadAddr.trim().isEmpty()) {
                fullAddress += roadAddr + " ";
            }
            if (detailAddr != null && !detailAddr.trim().isEmpty()) {
                fullAddress += detailAddr;
            }
            if (extraAddr != null && !extraAddr.trim().isEmpty()) {
                fullAddress += " (" + extraAddr + ")";
            }


            pstmt.setString(8, fullAddress.trim());

            // 체크박스는 미체크 시 null일 수 있음
            String agree = request.getParameter("user_agree");
            if (agree == null) {
                agree = "N";
            }
            pstmt.setString(9, agree);

            pstmt.setString(10, request.getParameter("user_join_path"));
            pstmt.setString(11, "0");
            pstmt.setString(12, "N");


            int result = pstmt.executeUpdate();

            if (result == 1) {
                System.out.println("회원가입 성공");
            }


        } catch (java.sql.SQLIntegrityConstraintViolationException e) {
            e.printStackTrace();
            request.setAttribute("msg", "이미 사용 중인 아이디 또는 이메일입니다.");
            request.setAttribute("redirectJoin", true);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("msg", "회원가입 중 오류가 발생했습니다.");
            request.setAttribute("redirectJoin", true);
        } finally {
            DBManager_new.close(con, pstmt, null);
        }
    }

    public static void UserUpdate(HttpServletRequest req) {

        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = "update users set user_name=?, user_pw=? where user_id=?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);

            String name = req.getParameter("name");
            String newPw = req.getParameter("newPw");
            String currentPw = req.getParameter("currentPw");
            String id = ((com.groot.app.user.UserDTO) req.getSession().getAttribute("loginUser")).getUser_id();

            System.out.println("=== UserUpdate Debug ===");
            System.out.println("name: " + name);
            System.out.println("newPw: " + newPw);
            System.out.println("currentPw: " + currentPw);
            System.out.println("id: " + id);
            System.out.println("Update completed successfully!");
            System.out.println("========================");

            // 이름만 업데이트 (비밀번호 변경은 별도 기능으로 분리)
            sql = "update users set user_name=? where user_id=?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, name);
            pstmt.setString(2, id);


            if (pstmt.executeUpdate() == 1) {
                System.out.println("수정 완료");

                // 세션의 loginUser 객체 업데이트
                UserDTO loginUser = (UserDTO) req.getSession().getAttribute("loginUser");
                loginUser.setName(name);
                req.getSession().setAttribute("loginUser", loginUser);
            }


        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, null);
        }
    }


    public static void UserDelete(HttpServletRequest req) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "delete users where user_id=?";
        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, req.getParameter("user_id"));
            if (pstmt.executeUpdate() == 1) {
                req.setAttribute("msg", "회원 탈퇴가 완료되었습니다.");
                System.out.println("회원 탈퇴 완료");
            } else {
                req.setAttribute("msg", "회원 탈퇴에 실패했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("msg", "회원 탈퇴 처리 중 오류가 발생했습니다.");
        } finally {
            DBManager_new.close(con, pstmt, null);
        }


    }


    public static boolean checkUserIdDuplicate(String userId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String sql = "SELECT COUNT(*) FROM users WHERE user_id = ?";

        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt(1);
                return count > 0; // count가 0보다 크면 중복
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }

        return false; // 에러 발생 시 중복 아님으로 처리
    }

    public static boolean isAdmin(HttpServletRequest request) {
        // 1. 세션 가져오기 (없으면 null 반환)
        HttpSession session = request.getSession(false);

        // 2. 세션이 없으면 당연히 관리자도 아님
        if (session == null) {
            return false;
        }

        // 3. 세션에서 isAdmin 값을 꺼내서 확인
        Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");

        // null 체크와 true 여부를 동시에 확인하여 반환
        return isAdmin != null && isAdmin;
    }
}

