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
}