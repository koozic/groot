package com.groot.app.recommendCW1.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecommendPairRuleDTO {
    private int ruleId;
    private int supplementId1;
    private String supplementName1;
    private int supplementId2;
    private String supplementName2;
    private String reason;
    private Integer intervalHours;
}
