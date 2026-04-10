create table users(
--     // 로그인
    user_id varchar2 (30 char) primary key,
    user_pw varchar2 (255 char) not null,
--      // 회원가입
    user_name varchar2 (30 char) not null,
    user_age number (3) not null,
    user_gender varchar2 (10 char) not null,
    user_profile varchar2 (1000 char) not null,
    user_email varchar2 (100 char) not null unique,
    user_address varchar2 (200 char),
    user_agree char (1) default 'N' not null,
    user_join_path varchar2(50 char),
--        // 실패 회수 , 이메일 본인 인증
    fail_count number default 0 not null,
    email_verified char(1) default 'N' not null

);



create sequence users_seq;


insert into users (
    user_id,
    user_pw,
    user_name,
    user_age,
    user_gender,
    user_profile,
    user_email,
    user_address,
    user_agree,
    user_join_path,
    fail_count,
    email_verified
) values (
             'kim124',
             '1235',
             '김도혁',
             25,
             '남',
             'https://upload.wikimedia.org/wikipedia/en/7/7c/Kiyotaka_Ayanokoji.png',
             'kim124@gmail.com',
             '서울시 종로구',
             'Y',
             'GOOGLE',
             0,
             'N'
         );

insert into users (
    user_id,
    user_pw,
    user_name,
    user_age,
    user_gender,
    user_profile,
    user_email,
    user_address,
    user_agree,
    user_join_path,
    fail_count,
    email_verified
) values (
             'lee02',
             '4321',
             '이민수',
             28,
             '남',
             'https://i.pinimg.com/originals/7d/3f/2b/7d3f2b6a5c4d3e2f1a0b9c8d7e6f5a4b.jpg',
             'lee03@gmail.com',
             '서울시 송파구',
             'Y',
             'FRIEND',
             0,
             'N'
         );

insert into users values (
             'park03',
             '3421',
             '박지영',
             24,
             '여',
             'https://i.pinimg.com/originals/6a/7c/9e/6a7c9e5b8d3a2b4c9d8f7e6a5c4b3a2d.jpg',
             'park023@gmail.com',
             '서울시 강동구',
             'Y',
             'INSTAGRAM',
             0,
             'N'
                         );

insert into users values (
            'choi04',
            '3434',
            '최현우',
            31,
            '남',
            'https://i.pinimg.com/originals/4b/6d/8f/4b6d8f1a2c3e4d5f6a7b8c9d0e1f2a3b.jpg',
            'choi0334@gmail.com',
            '부산시 해운대구',
            'Y',
            'SEARCH',
            0,
            'N'
                         );

insert into users values (
             'jung05',
             '4545',
             '정수빈',
             22,
             '여',
             'https://i.pinimg.com/originals/1a/5c/7e/1a5c7e9d8b6a4c3e2f1a0b9c8d7e6f5a.jpg',
             'jung045@gmail.com',
             '대구시 달서구',
             'Y',
             'YOUTUBE',
             0,
             'N'
                         );

insert into users values (
            'han06',
            '5656',
            '한지훈',
            35,
            '남',
            'https://i.pinimg.com/originals/5e/7a/9c/5e7a9c1b2d3f4a6c8e0f1a2b3c4d5e6f.jpg
',
            'han056@gmail.com',
            '인천시 남동구',
            'Y',
            'FRIEND',
            0,
            'N'
                         );

insert into users values (
            'kim07',
            '6767',
            '김나연',
            27,
            '여',
            'https://i.pinimg.com/originals/9c/1e/4d/9c1e4d7a6b5c4d3e2f1a0b9c8d7e6f5a.jpg',
            'kim067@gmail.com',
            '서울시 마포구',
            'Y',
            'INSTAGRAM',
            0,
            'N'
                         );

insert into users values (
            'yoon078',
            '7878',
            '윤태식',
            30,
            '남',
            'https://i.pinimg.com/originals/5e/7a/9c/5e7a9c1b2d3f4a6c8e0f1a2b3c4d5e6f.jpg',
            'yoon078@gmail.com',
            '광주시 북구',
            'Y',
            'SEARCH',
            0,
            'N'
                         );

insert into users values (
            'kang089',
            '8989',
            '강민지',
            26,
            '여',
            'https://cdn.myanimelist.net/images/characters/10/387741.jpg',
            'kang089@gmail.com',
            '대전시 서구',
            'Y',
            'YOUTUBE',
            0,
            'N'
                         );

insert into users values (
            'song10',
            '9090',
            '송준혁',
            29,
            '남',
            'https://i.pinimg.com/originals/3b/9d/6f/3b9d6f8a7c5e4d3f2b1a0c9d8e7f6a5b.jpg',
            'song090@gmail.com',
            '울산시 남구',
            'Y',
            'FRIEND',
            0,
            'N'
                         );

insert into users values (
            '123',
            '123',
            '임서연',
            23,
            '여',
            'https://cdn.myanimelist.net/images/characters/6/166001.jpg',
            'lim103@gmail.com1',
            '서울시 강서구',
            'Y',
            'SEARCH',
            0,
            'N'
                         );






select *
from users;



create table admin(
      admin_no number primary key,
      admin_id varchar2(30 char) unique not null,
      admin_pw varchar2(100 char) not null,
      admin_name varchar2(30 char) not null,
      admin_email varchar2(100 char) not null

);

create sequence u_admin;

insert into admin (
    admin_no,
    admin_id,
    admin_pw,
    admin_name,
    admin_email
) values (
             u_admin.nextval,
             'admin1',
             '1234',
             '관리자1',
             'admin1@test.com'
         );


insert into admin values (u_admin.nextval, 'master', '1111', '총관리자', 'master@test.com');
insert into admin values (u_admin.nextval, 'manager1', '2222', '운영관리자', 'manager1@test.com');
insert into admin values (u_admin.nextval, 'staff1', '3333', '스태프1', 'staff1@test.com');

select *
from admin;



ALTER TABLE USERS RENAME COLUMN USER_PROFILE_PATH TO user_profile;



