package com.groot.app.recommendCW1.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RecommendSupplementDTO {
    private int supplementId;
    private String supplementName;
    private String supplementTiming;
    private String supplementCaution;
    private String supplementImagePath;
    private int supplementViewCount;
}
