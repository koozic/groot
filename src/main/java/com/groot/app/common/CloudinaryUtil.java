package com.groot.app.common;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import javax.servlet.http.Part;
import java.io.IOException;
import java.util.Map;

public class CloudinaryUtil {
    private static Cloudinary cloudinary;

    public static void setCloudinary(Cloudinary c) {
        cloudinary = c;
    }

    public static Cloudinary getCloudinary() {
        return cloudinary;
    }

    public static String uploadFile(Part filePart, String supplements) throws IOException {
        if (filePart == null || filePart.getSize() == 0) return null;

        // 파일을 바이트 배열로 변환해서 업로드
        byte[] fileBytes = filePart.getInputStream().readAllBytes();
        Cloudinary cloudinary = CloudinaryUtil.getCloudinary();
        // Cloudinary에 업로드 실행
        Map uploadResult = cloudinary.uploader().upload(fileBytes, ObjectUtils.asMap(
                "folder", supplements
        ));
        // 업로드된 이미지의 '인터넷 주소(URL)'만 리턴
        return (String) uploadResult.get("url");
    }
}