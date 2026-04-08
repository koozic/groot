package com.groot.app.body;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AdminDTO {
    private int adminNo;
    private String adminId;
    private String adminPw;
    private String adminName;
    private String adminEmail;
}