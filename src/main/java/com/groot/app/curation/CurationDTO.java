package com.groot.app.curation;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CurationDTO {
    private int curationId;
    private String curationName;
    private String curationDescription;
    private int viewCount;
    private int likeCount;
    private String userId;
    private int bodyId;
    private String curationImage;

    // 북마크 여부 (마이페이지용)
    private boolean bookmarked;
}