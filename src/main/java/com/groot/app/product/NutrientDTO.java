package com.groot.app.product;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NutrientDTO {

    private int nutrientId;
    private String nutrientName;
    // Getter, Setter, 생성자 생략 (Lombok 사용 권장)
}
