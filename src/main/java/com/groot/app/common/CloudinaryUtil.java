package com.groot.app.common;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.IOException;
import java.util.Map;
import javax.servlet.http.Part; // 서블릿 사용 시

public class CloudinaryUtil {
    private static Cloudinary cloudinary;

    static {
        // 아까 메모장에 적어둔 정보를 여기에 넣으세요!
        cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", "doodfgsav",
                "api_key", "897682294648863",
                "api_secret", "1luj7MXmHGGa2qQiWaFgKS7um-A",
                "secure", true
        ));
    }

    public static String uploadFile(Part filePart, String supplements) throws IOException {
        if (filePart == null || filePart.getSize() == 0) return null;

        // 파일을 바이트 배열로 변환해서 업로드
        byte[] fileBytes = filePart.getInputStream().readAllBytes();

        // Cloudinary에 업로드 실행
        Map uploadResult = cloudinary.uploader().upload(fileBytes, ObjectUtils.asMap(
                "folder", supplements
        ));
        // 업로드된 이미지의 '인터넷 주소(URL)'만 리턴
        return (String) uploadResult.get("url");
    }
}
