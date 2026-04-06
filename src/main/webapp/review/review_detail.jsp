<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<div id="detail_content_inner" style="padding: 20px;">
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <h2 id="detail_title" style="margin: 0; color: #2c3e50;"></h2>
        <span onclick="closeDetailModal()" style="cursor: pointer; font-size: 28px; color: #aaa;">&times;</span>
    </div>

    <hr style="margin: 15px 0; border: 0; border-top: 1px solid #eee;">

    <div style="font-size: 0.9em; color: #7f8c8d; margin-bottom: 20px;">
        작성자: <span id="detail_user" style="font-weight: bold; color: #333;"></span> |
        별점: <span id="detail_score" style="color: #f1c40f;"></span>점 |
        날짜: <span id="detail_date"></span>
    </div>

    <div id="detail_img_box" style="text-align: center; margin-bottom: 20px; display: none;">
        <img id="detail_img" src="" style="max-width: 100%; border-radius: 10px;">
    </div>

    <div id="detail_text" style="line-height: 1.8; color: #444; min-height: 150px; white-space: pre-line; background: #fff; padding: 15px; border-radius: 5px;">
    </div>
</div>