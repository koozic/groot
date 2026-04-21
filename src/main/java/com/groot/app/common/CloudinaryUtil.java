package com.groot.app.common;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.Part;
import java.io.IOException;
import java.net.URI;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class CloudinaryUtil {
    private static Cloudinary cloudinary;
    private static final Pattern CLOUDINARY_UPLOAD_PATH_PATTERN =
            Pattern.compile("^/[^/]+/(image|video|raw)/upload(?:/[^/]+)*/v\\d+/(.+)$",
                    Pattern.CASE_INSENSITIVE);

    public static void setCloudinary(Cloudinary c) {
        cloudinary = c;
    }

    public static Cloudinary getCloudinary() {
        return cloudinary;
    }

    // 1. 기존 메서드: 변수명을 supplements -> folderName으로 변경해서 헷갈림 방지!
    public static String uploadFile(Part filePart, String folderName) throws IOException {
        if (filePart == null || filePart.getSize() == 0) return null;

        // 파일을 바이트 배열로 변환해서 업로드, 다까려면 ( 엄청큰 여러가지정보, 자바의 세계에서는 , 시각적자료임 ) 다 쪼개야됨
        byte[] fileBytes = filePart.getInputStream().readAllBytes();

        Cloudinary cloudinary = CloudinaryUtil.getCloudinary(); //얘가 회사랑 연결
        if (cloudinary == null) {
            System.out.println("[CloudinaryUtil] cloudinary is null - config not initialized");
            return null;
        }


        // folderName에 들어온 값("user", "product" 등)으로 폴더가 결정됨!
        // URL주소를 만들어줌.
        //json문자열로 바꿔준다.
        Map uploadResult = cloudinary.uploader().upload(fileBytes, ObjectUtils.asMap(

                "folder", folderName
        ));

        // secure_url 우선 사용, 없으면 url 사용
        String secureUrl = (String) uploadResult.get("secure_url");
        String url = (String) uploadResult.get("url");
        String finalUrl = (secureUrl != null && !secureUrl.isEmpty()) ? secureUrl : url;
        System.out.println("[CloudinaryUtil] upload success: " + finalUrl);
        return finalUrl;
    }

    // 2. 🚀 [새로 추가] 서블릿 코드를 단 한 줄로 만들어주는 마법의 메서드
    public static String uploadFromRequest(HttpServletRequest req, String partName, String folderName) {
        try {
            // request에서 파일을 꺼내서
            Part filePart = req.getPart(partName);
     System.out.println("[CloudinaryUtil] partName=" + partName
                    + ", submittedFileName=" + (filePart != null ? filePart.getSubmittedFileName() : "null")
                    + ", size=" + (filePart != null ? filePart.getSize() : -1));

            // 위에 있는 uploadFile을 실행해서 URL을 바로 받아옴!

            return uploadFile(filePart, folderName);
        } catch (Exception e) {
            e.printStackTrace();
            return null; // 파일이 없거나 에러나면 null
            //체크용ㄴ
        }
    }

    public static boolean isCloudinaryUrl(String fileUrl) {
        if (fileUrl == null || fileUrl.isBlank()) {
            return false;
        }

        try {
            URI uri = URI.create(fileUrl.trim());
            String host = uri.getHost();
            return host != null && host.toLowerCase().endsWith("res.cloudinary.com");
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean deleteFileByUrl(String fileUrl) {
        CloudinaryAsset asset = extractAsset(fileUrl);
        if (asset == null) {
            return false;
        }

        Cloudinary cloudinary = getCloudinary();
        if (cloudinary == null) {
            System.out.println("[CloudinaryUtil] cloudinary is null - delete skipped");
            return false;
        }

        try {
            Map destroyResult = cloudinary.uploader().destroy(asset.publicId, ObjectUtils.asMap(
                    "resource_type", asset.resourceType,
                    "invalidate", true
            ));
            String result = (String) destroyResult.get("result");
            boolean success = "ok".equalsIgnoreCase(result) || "not found".equalsIgnoreCase(result);

            System.out.println("[CloudinaryUtil] delete " + (success ? "success" : "failed")
                    + ": " + asset.publicId + " (" + result + ")");
            return success;
        } catch (Exception e) {
            System.out.println("[CloudinaryUtil] delete error: " + fileUrl);
            e.printStackTrace();
            return false;
        }
    }

    private static CloudinaryAsset extractAsset(String fileUrl) {
        if (!isCloudinaryUrl(fileUrl)) {
            return null;
        }

        try {
            URI uri = URI.create(fileUrl.trim());
            Matcher matcher = CLOUDINARY_UPLOAD_PATH_PATTERN.matcher(uri.getPath());
            if (!matcher.matches()) {
                System.out.println("[CloudinaryUtil] unsupported Cloudinary URL: " + fileUrl);
                return null;
            }

            String resourceType = matcher.group(1).toLowerCase();
            String publicId = stripExtension(matcher.group(2));
            if (publicId.isBlank()) {
                return null;
            }

            return new CloudinaryAsset(publicId, resourceType);
        } catch (Exception e) {
            System.out.println("[CloudinaryUtil] public_id parse error: " + fileUrl);
            e.printStackTrace();
            return null;
        }
    }

    private static String stripExtension(String value) {
        int lastSlash = value.lastIndexOf('/');
        int lastDot = value.lastIndexOf('.');

        if (lastDot > lastSlash) {
            return value.substring(0, lastDot);
        }
        return value;
    }

    private static class CloudinaryAsset {
        private final String publicId;
        private final String resourceType;

        private CloudinaryAsset(String publicId, String resourceType) {
            this.publicId = publicId;
            this.resourceType = resourceType;
        }
    }
}
