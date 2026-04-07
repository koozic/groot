<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div style="background:#fff; width:550px; margin:30px auto; border-radius:15px; padding:25px; position:relative; cursor:default;">
    <h2 style="margin-top:0;">📝 리뷰 수정하기</h2>

    <form id="updateForm" enctype="multipart/form-data">
        <input type="hidden" name="upd_review_id" id="upd_review_id">
        <input type="hidden" name="isImgDeleted" id="isImgDeleted" value="false">
        <input type="hidden" name="old_img_name" id="old_img_name">
        <input type="hidden" name="PRODUCT_ID" id="upd_p_id">

        <div style="margin-bottom:15px;">
            <label style="font-weight: bold;">제목</label><br>
            <input type="text" name="upd_title" id="upd_title" style="width:100%; padding:8px; border:1px solid #ddd; border-radius:5px;">
        </div>

        <div style="margin-bottom:15px;">
            <label style="font-weight: bold; display: block; margin-bottom: 5px;">별점</label>
            <input type="hidden" name="upd_score" id="upd_score" value="5">
            <div id="upd_star_container">
                <span class="upd-star" data-value="1">★</span>
                <span class="upd-star" data-value="2">★</span>
                <span class="upd-star" data-value="3">★</span>
                <span class="upd-star" data-value="4">★</span>
                <span class="upd-star" data-value="5">★</span>
            </div>
        </div>

        <div style="margin-bottom:15px;">
            <label style="font-weight: bold;">내용</label>
            <textarea name="upd_content" id="upd_content" rows="5" maxlength="500" oninput="updateCharCount()" style="width:100%; padding:8px; border:1px solid #ddd; border-radius:5px; resize:none;"></textarea>
            <div style="text-align:right; font-size:0.85em; color:#888; margin-top:5px;">
                <span id="charCount" style="font-weight:bold; color:#6a8d3a;">0</span> / 500자
            </div>
        </div>
        <div style="margin-bottom:20px;">
            <label style="font-weight: bold;">사진 수정</label>
            <input type="file" name="upd_file" id="upd_file" accept="image/*" style="display: block; margin-top: 10px;">
            <p style="font-size: 0.8em; color: #999;">* 새로운 사진을 선택하면 기존 사진이 교체됩니다.</p>

            <div id="existing_img_box" style="margin-top: 10px; display: none; padding: 10px; background: #f9f9f9; border-radius: 5px;">
                <p style="margin: 0 0 5px 0; font-size: 0.9em; color: #555;">📸 현재 등록된 사진이 있습니다.</p>

                <img id="preview_old_img" src="" style="width: 80px; height: 80px; object-fit: cover; border-radius: 5px; margin-bottom: 10px; display: block; border: 1px solid #ddd;">

                <label style="cursor: pointer; color: #e74c3c; font-weight: bold; font-size: 0.9em;">
                    <input type="checkbox" id="delete_img_check" onchange="toggleImgDelete()"> 이 사진을 완전히 삭제하고 글만 남기기
                </label>
            </div>
        </div>

        <div style="display:flex; gap:10px;">
            <button type="button" onclick="submitUpdate()" style="flex:1; background:#6a8d3a; color:white; border:none; padding:12px; border-radius:8px; font-weight:bold; cursor:pointer;">수정 완료</button>
            <button type="button" onclick="closeUpdateModal()" style="flex:1; background:#eee; border:none; padding:12px; border-radius:8px; cursor:pointer;">취소</button>
        </div>
    </form>
</div>