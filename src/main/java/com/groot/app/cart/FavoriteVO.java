package com.groot.app.cart;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 관심제품(장바구니/찜) VO
 * 테이블: favorite_products
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteVO {

    private int   favorite_id;
    private String user_id;
    private int    product_id;

    // products 테이블 JOIN용
    private String product_name;
    private String product_brand;
    private int    product_price;
    private String product_image;
}

