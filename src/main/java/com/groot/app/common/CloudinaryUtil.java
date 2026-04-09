package com.groot.app.common;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import javax.servlet.http.HttpServletRequest;
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

    // 1. 기존 메서드: 변수명을 supplements -> folderName으로 변경해서 헷갈림 방지!
    public static String uploadFile(Part filePart, String folderName) throws IOException {
        if (filePart == null || filePart.getSize() == 0) return null;

        // 파일을 바이트 배열로 변환해서 업로드
        byte[] fileBytes = filePart.getInputStream().readAllBytes();

        //json문자열로 바꿔준다.
        Cloudinary cloudinary = CloudinaryUtil.getCloudinary();

        // folderName에 들어온 값("user", "product" 등)으로 폴더가 결정됨!
        // URL주소를 만들어줌.

        Map uploadResult = cloudinary.uploader().upload(fileBytes, ObjectUtils.asMap(
                "folder", folderName
        ));

        // 업로드된 이미지의 '인터넷 주소(URL)'만 리턴
        return (String) uploadResult.get("url");
    }

    // 2. 🚀 [새로 추가] 서블릿 코드를 단 한 줄로 만들어주는 마법의 메서드
    public static String uploadFromRequest(HttpServletRequest req, String partName, String folderName) {
        try {
            // request에서 파일을 꺼내서
            Part filePart = req.getPart(partName);
            // 위에 있는 uploadFile을 실행해서 URL을 바로 받아옴!
            return uploadFile(filePart, folderName);
        } catch (Exception e) {
            e.printStackTrace();
            return null; // 파일이 없거나 에러나면 null
            //체크용ㄴ
        }
    }
}