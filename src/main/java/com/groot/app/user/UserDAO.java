package com.groot.app.user;

import com.groot.app.main.DBManager_new;
import com.oreilly.servlet.MultipartRequest;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
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


                    System.out.println("프로필 이미지: " + rs.getString("user_profile"));
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
        ResultSet rs = null;
        String sql = "insert into users values (users_seq.nextval,?,?,?,?,?,?,?,?,?,?,?,?)";
        try {
            con = DBManager_new.connect();
            pstmt = con.prepareStatement(sql);


        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);
        }


    }
}

