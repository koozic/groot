package com.groot.app.user;

import com.groot.app.main.DBManager_new;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {
    public static void Login(HttpServletRequest request) {
        String id = request.getParameter("user_id");
        String pw = request.getParameter("user_pw");

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "select * from users where user_id=?";
        try {
          con = DBManager_new.connect();
          pstmt = con.prepareStatement(sql);
          pstmt.setString(1, request.getParameter("user_id"));
          rs = pstmt.executeQuery();
          String loginMsg = "";
          if (rs.next()) {
              if (rs.getString("user_pw").equals(pw)) {
                  // 로그인 성공
                  System.out.println("어서오세요. 당신의 건강을 챙기세요");
                  loginMsg = "어서오세요. 당신의 건강을 챙기세요";

              } else {
                  // 로그인 실패
                  System.out.println("다시 로그인 해주세요 (5회 이상 실패 시 본인인증) ");
                  loginMsg = "다시 로그인 해주세요 (5회 이상 실패 시 본인인증) ";

              }

          } else {
              // 신규 회원
              System.out.println("새로 오셨네요. 회원가입 해주세요");
              loginMsg = "새로 오셨네요. 회원가입 해주세요";
          }

            request.setAttribute("loginMsg", loginMsg);









        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBManager_new.close(con, pstmt, rs);

        }




    }
}
