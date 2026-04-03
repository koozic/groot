package com.groot.app.supplements;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Date;

@Data   // Getter / Setter (데이터를 넣고 빼기 위한 메서드)
@AllArgsConstructor
@NoArgsConstructor

// DTO 역할 : 데이터베이스의 supplements 테이블에서 꺼낸 영양성분 한 줄(Row)의 데이터를 자바 객체로 담아두는 역할

public class SupplementsDTO {
    // 1. 멤버 변수 (테이블 컬럼과 매칭)
    private int sNo;
    private String sName;
    private String sEfficacy;
    private String sDosage;
    private String sTiming;
    private String sCaution;
    private String sImagePath;
    private Date sRegDate;
    private int sViewCount;
}
