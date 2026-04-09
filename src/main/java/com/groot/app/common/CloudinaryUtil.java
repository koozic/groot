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

        Cloudinary cloudinary = CloudinaryUtil.getCloudinary(); //얘가 회사까지 전달

        // folderName에 들어온 값("user", "product" 등)으로 폴더가 결정됨! , 여기에서 폴더거 결정됨! 여기서 회사에서처리
        Map uploadResult = cloudinary.uploader().upload(fileBytes, ObjectUtils.asMap( //json으로 변환하는 과정에  Url이 생김
                "folder", folderName
        ));

        // 업로드된 이미지의 '인터넷 주소(URL)'만 리턴
        return (String) uploadResult.get("url"); //url = String
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