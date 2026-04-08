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
        System.out.println("=== AppConfigListener 실행됨 ===");

        try {
            Properties props = new Properties();

            InputStream input = sce.getServletContext().getResourceAsStream("/WEB-INF/config.properties");
            System.out.println("input: " + input);

            if (input != null) {
                props.load(input);
                input.close();

                Cloudinary cloudinary = new Cloudinary(ObjectUtils.asMap(
                        "cloud_name", props.getProperty("cloud_name"),
                        "api_key", props.getProperty("api_key"),
                        "api_secret", props.getProperty("api_secret"),
                        "secure", Boolean.parseBoolean(props.getProperty("secure").trim())
                ));

                CloudinaryUtil.setCloudinary(cloudinary);

                System.out.println("Cloudinary 설정 완료");
                System.out.println("cloud_name = " + props.getProperty("cloud_name"));
                System.out.println("저장 직후 = " + CloudinaryUtil.getCloudinary());
            } else {
                System.out.println("config.properties 못 찾음");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // 필요 없으면 비워둬도 됨
    }
}