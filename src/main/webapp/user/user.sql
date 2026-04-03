create table users(
--     // 로그인
    user_id varchar2 (30 char) primary key,
    user_pw varchar2 (255 char) not null,
--      // 회원가입
    user_name varchar2 (30 char) not null,
    user_age number (3) not null,
    user_gender varchar2 (10 char) not null,
    user_profile varchar2 (200 char) not null,
    user_email varchar2 (100 char) not null unique,
    user_address varchar2 (200 char),
    user_agree char (1) default 'N' not null,
    user_join_path varchar2(50 char)


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
    user_join_path
) values (
             'kim123',
             '1234',
             '김도혁',
             25,
             '남',
             'img/default.png',
             'kim123@gmail.com',
             '서울시 강남구',
             'Y',
             'GOOGLE'
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
    user_join_path
) values (
             'lee01',
             '1111',
             '이민수',
             28,
             '남',
             'img/default.png',
             'lee01@gmail.com',
             '서울시 송파구',
             'Y',
             'FRIEND'
         );

insert into users values (
             'park02',
             '2222',
             '박지영',
             24,
             '여',
             'img/default.png',
             'park02@gmail.com',
             '서울시 강동구',
             'Y',
             'INSTAGRAM'
                         );

insert into users values (
            'choi03',
            '3333',
            '최현우',
            31,
            '남',
            'img/default.png',
            'choi03@gmail.com',
            '부산시 해운대구',
            'Y',
            'SEARCH'
                         );

insert into users values (
             'jung04',
             '4444',
             '정수빈',
             22,
             '여',
             'img/default.png',
             'jung04@gmail.com',
             '대구시 달서구',
             'Y',
             'YOUTUBE'
                         );

insert into users values (
            'han05',
            '5555',
            '한지훈',
            35,
            '남',
            'img/default.png',
            'han05@gmail.com',
            '인천시 남동구',
            'Y',
            'FRIEND'
                         );

insert into users values (
            'kim06',
            '6666',
            '김나연',
            27,
            '여',
            'img/default.png',
            'kim06@gmail.com',
            '서울시 마포구',
            'Y',
            'INSTAGRAM'
                         );

insert into users values (
            'yoon07',
            '7777',
            '윤태식',
            30,
            '남',
            'img/default.png',
            'yoon07@gmail.com',
            '광주시 북구',
            'Y',
            'SEARCH'
                         );

insert into users values (
            'kang08',
            '8888',
            '강민지',
            26,
            '여',
            'img/default.png',
            'kang08@gmail.com',
            '대전시 서구',
            'Y',
            'YOUTUBE'
                         );

insert into users values (
            'song09',
            '9999',
            '송준혁',
            29,
            '남',
            'img/default.png',
            'song09@gmail.com',
            '울산시 남구',
            'Y',
            'FRIEND'
                         );

insert into users values (
            'lim10',
            '1010',
            '임서연',
            23,
            '여',
            'img/default.png',
            'lim10@gmail.com',
            '서울시 강서구',
            'Y',
            'SEARCH'
                         );






select *
from users;
