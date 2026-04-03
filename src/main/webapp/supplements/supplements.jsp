<%--브라우저에게 "이 문서는 HTML이고, 한글이 깨지지 않도록 UTF-8 인코딩을 사용해라.
그리고 안에서 Java 언어를 쓸 거다"라고 알려주는 지시어--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--<% %> 같은 자바 코드를 쓰지 않고도 반복문이나 조건문을
HTML 태그처럼 쓰게 해주는 JSTL(JavaServer Pages Standard Tag Library)을 불러옵니다.
앞으로 <c: 로 시작하는 태그를 쓰겠다는 약속--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <title>영양성분 리스트 및 관리</title>
    <style>
        /* 예시 코드의 클래스명에 맞춘 기본적인 CSS 스타일 */
        .supp-reg { border: 1px solid #ccc; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .supp-reg > div { margin-bottom: 10px; display: flex; align-items: center; }
        .supp-reg > div > div:first-child { width: 100px; font-weight: bold; }

        .supp-container { display: flex; flex-wrap: wrap; gap: 20px; justify-content: center; margin-bottom: 20px; }
        .supp-wrap { border: 1px solid #ddd; padding: 15px; border-radius: 8px; width: 250px; text-align: center; }
        .supp-img img { width: 100%; height: 200px; object-fit: cover; cursor: pointer; border-radius: 4px; }

        .supp-title { font-size: 1.2em; font-weight: bold; margin: 10px 0; }
        .supp-efficacy { color: #666; font-size: 0.9em; height: 40px; overflow: hidden; margin-bottom: 10px; }

        .supp-btn { padding: 5px 10px; cursor: pointer; background-color: #f0f0f0; border: 1px solid #ccc; border-radius: 4px; }
        .supp-btn:hover { background-color: #e0e0e0; }

        .pagination { text-align: center; margin: 20px 0; }
        .pn.shake { color: #ccc; cursor: not-allowed; }
    </style>
</head>

<body>
<h1 style="text-align: center;">영양성분 관리 페이지</h1>

<div style="display: flex; justify-content: center;">
<%-- action="insertSupp.do": '등록하기' 버튼을 누르면 데이터를 들고 insertSupp.do라는 주소(서블릿)로 찾아가라는 뜻 --%>
<%-- <input type="file">을 사용해 이미지를 첨부하려면 반드시 이 속성을 써야함 --%>
    <form action="supplements" method="get" enctype="multipart/form-data">
        <div class="supp-reg">
            <div>
                <div>성분명</div>
                <%-- 서블릿(Controller)에서 이 값을 꺼낼 때 사용하는 이름표(Key)입니다.
                자바 코드에서 request.getParameter("sName")이라고 쓰면 사용자가 입력한 텍스트를 가져올 수 있습니다. --%>
<%--            <%-- required: HTML5 기능으로, 이 칸을 비워두고 버튼을 누르면 "이 입력란을 작성하세요"라는 경고창을 띄워주는 방어막 --%>
                <div><input type="text" name="sName" required></div>
            </div>
            <div>
                <div>권장 복용량</div>
                <div><input type="text" name="sDosage"></div>
            </div>
            <div>
                <div>이미지 파일</div>
                <div><input type="file" name="file"></div>
            </div>
            <div>
                <div>상세 효능</div>
                <div><textarea rows="5" cols="40" name="sEfficacy" required></textarea></div>
            </div>
            <div style="justify-content: center;">
                <button type="submit" class="supp-btn">등록하기</button>
            </div>
        </div>
    </form>
</div>
<hr>

<div style="width: 100%; display: flex; flex-direction: column; align-items: center;">
    <div class="supp-container">
    <%-- items="${sList}": 서블릿이 request.setAttribute("sList", 리스트데이터)로 담아준 전체 영양성분 리스트를 꺼내옵니다.
    (EL 표현식 ${...} 사용) --%>
    <%-- var="supp": 리스트에서 하나씩 꺼낸 데이터를 supp라는 변수에 담아 아래쪽에서 쓰겠다는 뜻 --%>
        <c:forEach var="supp" items="${sList}">

            <div class="supp-wrap">
            <%-- ?sNo=${supp.sNo}: 이동할 때 URL 뒤에 물음표(?)를 붙여서
            "내가 클릭한 영양성분의 고유번호(sNo)가 이거야!"라고 서블릿에게 몰래 알려주는 부분입니다.
            (이를 쿼리 스트링이라고 합니다.) --%>
                <div class="supp-img" onclick="location.href='detailSupp.do?sNo=${supp.sNo}'">
                <%-- ${supp.sName}: 화면에 출력하는 EL 표현식입니다.
                우리가 굳이 supp.getsName()이라고 자바 코드를 길게 쓰지 않아도,
                서버가 알아서 Getter 메서드를 호출해 글자로 바꿔줍니다. --%>
                    <img alt="${supp.sName}" src="/images/${supp.sImagePath}">
                </div>

                <div class="supp-title">${supp.sName}</div>
                <div class="supp-efficacy">${supp.sEfficacy}</div>

                <div>
                    <%-- 삭제 버튼을 누르면 제일 아래쪽에 만들어둔 delSupp라는 자바스크립트 함수를 실행합니다.
                    이때 괄호 안에 어떤 번호를 삭제할지(${supp.sNo})를 던져줍니다. --%>
                    <button class="supp-btn" onclick="delSupp('${supp.sNo}')">삭제</button>
                    <button class="supp-btn" onclick="location.href='updateSupp.do?sNo=${supp.sNo}'">수정</button>
                </div>
            </div>

        </c:forEach>
    </div>

    <div class="pagination">
        <%-- <c:choose>: JSTL의 조건문 블록을 엽니다. 자바의 switch나 if-else문과 같습니다. --%>
        <c:choose>
        <%-- <c:when test="...">: 조건이 참(true)일 때 실행됩니다. 만약 현재 페이지가 1페이지가 아니라면 (즉, 2페이지 이상이라면)
        정상적인 작동을 하는 '이전' 버튼을 보여줍니다. 누르면 현재 페이지 번호에서 1을 뺀 번호로 이동(list.do?p=...)합니다. --%>
            <c:when test="${currentPage != 1}">
                <button class="supp-btn pn" onclick="location.href='list.do?p=${currentPage - 1}'">이전</button>
            </c:when>
            <%-- <c:otherwise>: 위 조건이 거짓일 때 실행됩니다. 현재 페이지가 1페이지라면 더 이상 뒤로 갈 수 없으므로,
            클릭이 안 되는(disabled) 회색 가짜 버튼을 보여줍니다.--%>
            <c:otherwise>
                <button class="supp-btn pn shake" disabled>이전</button>
            </c:otherwise>
        </c:choose>

        <c:choose>
            <c:when test="${currentPage != totalPage}">
                <button class="supp-btn pn" onclick="location.href='list.do?p=${currentPage + 1}'">다음</button>
            </c:when>
            <c:otherwise>
                <button class="supp-btn pn shake" disabled>다음</button>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="pagination">
        <a href="list.do?p=1">[처음]</a>
        <%-- 숫자를 1(begin)부터 총 페이지 수(end)까지 1씩 증가시키면서 i라는 변수에 담아 반복합니다.
        즉 [1] [2] [3] 처럼 페이지 번호 링크를 화면에 주르륵 찍어내는 코드입니다. --%>
        <c:forEach begin="1" end="${totalPage}" var="i">
            <a href="list.do?p=${i}">[${i}]</a>
        </c:forEach>

        <a href="list.do?p=${totalPage}">[끝]</a>
    </div>
</div>

<script>
    // 삭제 전 확인 창을 띄우는 함수
    function delSupp(sNo) {
        let ok = confirm('정말로 이 영양성분 정보를 삭제하시겠습니까?');
        if(ok){
            // 사용자가 '확인'을 누르면 삭제 서블릿으로 요청을 보냄
            location.href = 'deleteSupp.do?sNo=' + sNo;
        }
    }
</script>
        <%-- confirm('...'): 브라우저에 [확인] / [취소] 버튼이 있는 알림창을 띄웁니다.
        사용자가 [확인]을 누르면 true를, [취소]를 누르면 false를 ok 변수에 담습니다.
        if(ok): 사용자가 [확인]을 눌렀을 때만 작동합니다.
        location.href = ...: 브라우저의 주소창을 강제로 바꿔서 deleteSupp.do 서블릿으로 이동시킵니다.
        이때 아까 버튼에서 넘겨받은 고유번호(sNo)를 달아서 보내므로,
        서블릿이 DB에서 정확히 그 번호를 찾아 삭제할 수 있게 됩니다. --%>

</body>
</html>