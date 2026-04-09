package com.groot.app.review;

import java.util.Date;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ReviewDTO {
    private int review_id;      // PK
    private String user_id;     // 작성자
    private int product_id;    // 상품 번호 (FK)
    private String r_title;     // 리뷰 제목
    private String r_content;   // 리뷰 내용
    private int r_score;        // 별점
    private String r_img;       // 사진 경로
    private Date r_date;        // 작성일
    private int r_like;         // 좋아요 수

    // ==========================================
    // 🌟 [추가] 메인 화면 베스트 리뷰 출력을 위한 조인(JOIN)용 변수들
    // ==========================================
    private String p_name;           // 제품명 (PRODUCTS 테이블)
    private String p_img;            // 제품 이미지 (PRODUCTS 테이블)
    private String supp_name;        // 영양성분명 (SUPPLEMENTS 테이블 - 예: '비타민 C')
    private double p_avg_score;      // 해당 제품의 평균 별점 (연산 필요)
}