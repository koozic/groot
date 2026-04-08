package com.groot.app.mypage;

public class DailyCheckDTO {
    private int productId;
    private String productName;
    private String productImage;
    private String productTimeInfo;
    private int productServe;
    private boolean checkedToday;     // 오늘 복용 여부
    private int totalTakenCount;      // 누적 복용 일수

    // Getter, Setter 생략 (또는 Lombok @Data 사용)
}
