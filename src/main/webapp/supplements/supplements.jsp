<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--contentType 및 pageEncoding: 이 페이지가 한글이 깨지지 않는 UTF-8 인코딩의 HTML 문서임을 브라우저에 알려줍니다.--%>
<!DOCTYPE html>
<html>
<head>
    <title>영양성분 리스트</title>

    <style>
        .container { width: 80%; margin: 0 auto; display: flex; flex-wrap: wrap; gap: 20px; }
        .card { border: 1px solid #ddd; border-radius: 8px; width: 300px; overflow: hidden; box-shadow: 2px 2px 10px rgba(0,0,0,0.1); }
        .card img { width: 100%; height: 200px; object-fit: cover; }
        .card-body { padding: 15px; }
        .card-title { font-size: 1.2em; font-weight: bold; margin-bottom: 10px; }
        .card-text { color: #666; font-size: 0.9em; height: 40px; overflow: hidden; }
        .btn-detail { display: inline-block; margin-top: 10px; color: #007bff; text-decoration: none; }
    </style>
<body>
<%--역할 : 컨트롤러가 보내준 sList를 꺼내어 화면에 반복문으로 출력합니다.--%>
<h1><%= "Hello World!" %>
</h1>
<br/>
<a href="hello-servlet">Hello Servlet</a>
<h1>my name is eunsa!</h1>
</body>
</html>