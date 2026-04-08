package com.groot.app.common;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import java.io.IOException;
import java.util.Map;
import java.io.InputStream;
import java.util.Properties;
import javax.servlet.http.Part; // 서블릿 사용 시

public class CloudinaryUtil {
    private static Cloudinary cloudinary;

    static {
        try {
            Properties props = new Properties();
            InputStream input = CloudinaryUtil.class.getClassLoader().getResourceAsStream("config.properties");
            if (input != null) {
                props.load(input);
                cloudinary = new Cloudinary(ObjectUtils.asMap(
                    "cloud_name", props.getProperty("cloud_name"),
                    "api_key", props.getProperty("api_key"),
                    "api_secret", props.getProperty("api_secret"),
                    "secure", Boolean.parseBoolean(props.getProperty("secure", "true"))
                ));
                input.close();
            } else {
                throw new RuntimeException("config.properties file not found");
            }
        } catch (IOException e) {
            throw new RuntimeException("Failed to load Cloudinary configuration", e);
        }
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
