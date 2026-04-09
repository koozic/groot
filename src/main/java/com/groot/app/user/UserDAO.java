package com.groot.app.user;

import com.groot.app.common.CloudinaryUtil;
import com.groot.app.main.DBManager_new;
import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

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
                    // [로그인 성공]
                    UserDTO user = new UserDTO();
                    user.setUser_id(rs.getString("user_id"));
                    user.setName(rs.getString("user_name"));
                    user.setEmail(rs.getString("user_email"));
                    user.setAge(rs.getInt("user_age"));
                    user.setGender(rs.getString("user_gender"));
                    user.setUser_profile(rs.getString("user_profile"));


                    String profileImg = rs.getString("user_profile");
                    System.out.println("=== Login Debug ===");
                    System.out.println("프로필 이미지: " + profileImg);
                    System.out.println("UserDTO profile: " + user.getUser_profile());
                    System.out.println("==================");
                    System.out.println("어서오세요. 당신의 건강을 챙기세요");
                    loginMsg = "어서오세요. 당신의 건강을 챙기세요";

                    request.getSession().setAttribute("loginUser", user);
                    request.getSession().removeAttribute("loginFailCount"); // 실패 카운트 초기화

                    isLoginSuccess = true; // 성공 상태로 변경

                } else {
                    // [로그인 실패 - 비밀번호 불일치]
                    incrementFailCount(request, id);
                    System.out.println("다시 로그인 해주세요 (5회 이상 실패 시 본인인증)");
                    loginMsg = "아이디 또는 비밀번호가 일치하지 않습니다. (5회 이상 실패 시 본인인증)";
                }

            } else {
                // [로그인 실패 - 신규 회원 (없는 아이디)]
                incrementFailCount(request, id);
                System.out.println("새로 오셨네요. 회원가입 해주세요");
                loginMsg = "존재하지 않는 아이디입니다. 회원가입 해주세요";
                request.setAttribute("needVerifyChoice", true);
            }

            // 성공이든 실패든 메시지는 request에 담아줌
            request.setAttribute("loginMsg", loginMsg);


        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }

        // 컨트롤러에게 로그인 성공 여부를 반환
        return isLoginSuccess;
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

    public static void ProfileUpdate(HttpServletRequest request) {

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
            con=DBManager_new.connect();
            pstmt = con.prepareStatement(sql);

            pstmt.setString(1, request.getParameter("user_id"));
            pstmt.setString(2, request.getParameter("user_pw"));
            pstmt.setString(3, request.getParameter("user_name"));
            pstmt.setInt(4, Integer.parseInt(request.getParameter("user_age")));
            pstmt.setString(5, request.getParameter("user_gender"));

            // =========================
            // 프로필 이미지 처리
            // =========================
            String selectedProfile = request.getParameter("user_profile");   // 라디오 선택값
            Part profileFile = request.getPart("user_profile_file");            // 파일 업로드
            String finalProfilePath = null;

            // 직접 업로드가 있으면 Cloudinary 우선
            if (profileFile != null && profileFile.getSize() > 0) {
                try {
                    finalProfilePath = CloudinaryUtil.uploadFile(profileFile, "users");
                    System.out.println("직접 업로드 이미지 URL: " + finalProfilePath);
                } catch (Exception e) {
                    System.out.println("Cloudinary 업로드 실패, 기본 프로필 사용: " + e.getMessage());
                    finalProfilePath = "user/userimg/Ayanokoji.jfif";
                }
            }
            // 업로드 없으면 기본 프로필 사용
            else if (selectedProfile != null && !selectedProfile.trim().isEmpty()) {
                finalProfilePath = "user/userimg/" + selectedProfile;
                System.out.println("기본 프로필 선택: " + finalProfilePath);
            }
            // 혹시 모를 예외 대비
            else {
                finalProfilePath = "user/userimg/Ayanokoji.jfif";
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

        } catch (Exception e) {
            e.printStackTrace();
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

           if (pstmt.executeUpdate() == 1){
               System.out.println("수정 완료");
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
               if (pstmt.executeUpdate() == 1){
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
}

