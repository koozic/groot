package com.groot.app.product;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProductDTO {
    private int product_id;
    private String product_admin;
    private String product_Name;
    private String product_Brand;
    private int product_price;
    private int product_nutrient;
    private String product_description;
    private String product_img;
    private int product_total;
    private int product_serve;
    private int product_per_day;
    private String product_time_info;
    private Date product_start_date;
    private int product_current;
}
