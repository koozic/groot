package com.groot.app.body;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor

public class BodyDTO {
    // 신체 부위 정보
    private int bodyId;
    private String bodyName;
    private String bodyImage;

    // 영양소 정보 (body_supplement JOIN supplements)
    private int supplementId;
    private String supplementName;
    private String supplementEfficacy;
    private String supplementDosage;
    private String supplementTiming;
    private String supplementCaution;
    private String supplementImagePath;
    private int supplementViewCount;
    private int likeCount; // supplements_like 집계용
}
