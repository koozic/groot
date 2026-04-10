package com.groot.app.user;

import javax.mail.*; // jakarta 대신 javax로 변경
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

import java.util.Properties;


public class MailSender {

    private static final String FROM_EMAIL = "200107qs@naver.com";
    private static final String NAVER_ID = "200107qs"; // @naver.com 제외한 아이디만
    private static final String APP_PASSWORD = "UYSLD9RGHGED";

    public static void sendAuthMail(String toEmail, String authCode) throws Exception {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.naver.com");
        props.put("mail.smtp.port", "465");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.ssl.enable", "true"); // SSL 사용
        props.put("mail.smtp.ssl.trust", "smtp.naver.com");

        // Session 생성 시 Authenticator 익명 클래스 확인
        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(NAVER_ID, APP_PASSWORD);
            }
        });

        // 디버그 모드 활성화 (콘솔에 SMTP 통신 과정이 찍힙니다)
        session.setDebug(true);

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL, "Groot", "UTF-8"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        // 제목에 한글이 있을 경우 인코딩 지정
        message.setSubject("[Groot] 회원가입 인증번호");

// setText는 인자를 하나만 넣어야 에러가 나지 않습니다.
        message.setText("인증번호: [" + authCode + "]");

        Transport.send(message);
    }



}
