package com.groot.app.product;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductDTO {
    private int productId;
    private String productAdmin;
    private String productName;
    private String productBrand;
    private int productPrice;
    private int productNutrient;
    private String productDescription;
    private String productImage;
    private int productTotal;
    private int productServe;
    private int productPerDay;
    private String productTimeInfo;
    private Date productStartDate;
    private int productCurrent;
}
