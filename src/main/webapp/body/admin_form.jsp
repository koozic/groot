<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>${empty supp ? '영양소 등록' : '영양소 수정'}</title>
    <style>
        body {
            font-family: sans-serif;
            padding: 30px;
            max-width: 600px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        label {
            display: block;
            font-weight: bold;
            margin-bottom: 5px;
        }

        input, textarea, select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }

        textarea {
            height: 80px;
            resize: vertical;
        }

        .btn-submit {
            background: #4CAF50;
            color: white;
            padding: 10px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1em;
        }

        .btn-cancel {
            background: #9e9e9e;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-left: 10px;
        }
    </style>
</head>
<body>

<%-- supp가 null이면 등록, 있으면 수정 --%>
<h2>${empty supp ? '➕ 영양소 등록' : '✏️ 영양소 수정'}</h2>

<form action="admin" method="post">
    <%-- action 구분 --%>
    <input type="hidden" name="action"
           value="${empty supp ? 'insert' : 'update'}">

    <%-- 수정 시 suppId 전달 --%>
    <c:if test="${not empty supp}">
        <input type="hidden" name="suppId" value="${supp.supplementId}">
    </c:if>

    <div class="form-group">
        <label>영양소 이름 *</label>
        <input type="text" name="supplementName"
               value="${supp.supplementName}" required
               placeholder="예: 루테인">
    </div>

    <div class="form-group">
        <label>효능 *</label>
        <textarea name="supplementEfficacy"
                  required
                  placeholder="예: 눈 건강 보호 및 황반변성 예방">${supp.supplementEfficacy}</textarea>
    </div>

    <div class="form-group">
        <label>복용법</label>
        <input type="text" name="supplementDosage"
               value="${supp.supplementDosage}"
               placeholder="예: 하루 1정 (20mg)">
    </div>

    <div class="form-group">
        <label>복용 시기</label>
        <input type="text" name="supplementTiming"
               value="${supp.supplementTiming}"
               placeholder="예: 식후 복용">
    </div>

    <div class="form-group">
        <label>주의사항</label>
        <textarea name="supplementCaution"
                  placeholder="예: 과다복용 시 피부 황변 가능">${supp.supplementCaution}</textarea>
    </div>

    <div class="form-group">
        <label>이미지 경로</label>
        <input type="text" name="supplementImagePath"
               value="${supp.supplementImagePath}"
               placeholder="예: images/supp/lutein.png">
    </div>

    <%-- 등록 시에만 신체 부위 선택 표시 --%>
    <c:if test="${empty supp}">
        <div class="form-group">
            <label>연결할 신체 부위</label>
            <select name="bodyId">
                <option value="">선택 안함</option>
                <option value="1">👁️ 눈</option>
                <option value="2">🥩 간</option>
                <option value="3">💤 피로개선</option>
                <option value="4">🦴 뼈/관절</option>
            </select>
        </div>
    </c:if>

    <button type="submit" class="btn-submit">
        ${empty supp ? '등록하기' : '수정하기'}
    </button>
    <button type="button" class="btn-cancel"
            onclick="location.href='admin'">취소
    </button>
</form>

</body>
</html>
