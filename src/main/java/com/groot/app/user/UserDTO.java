package com.groot.app.user;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.servlet.http.HttpSession;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class UserDTO {
   private String user_id;
   private String user_pw;
   private String name;
   private int age;
   private String gender;
   private String user_profile;
   private String email;
   private String address;
   private boolean agree;
   private String path;









}
