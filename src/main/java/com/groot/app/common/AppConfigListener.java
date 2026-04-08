package com.groot.app.common;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.io.InputStream;
import java.util.Properties;

@WebListener
public class AppConfigListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            Properties props = new Properties();
            // ServletContext를 통해 WEB-INF 안의 파일을 정확히 가리킴
            InputStream input = sce.getServletContext().getResourceAsStream("/WEB-INF/config.properties");

            if (input != null) {
                props.load(input);
                Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
                        "cloud_name", props.getProperty("cloud_name"),
                        "api_key", props.getProperty("api_key"),
                        "api_secret", props.getProperty("api_secret")
                ));
                // 공용 저장소(Context)에 보관하거나 Util의 setter로 전달
                CloudinaryUtil.setCloudinary(cloudinary);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}