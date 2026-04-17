<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<div class="recommend-container"
     id="recommendPage"
     data-reco-base-path="${pageContext.request.contextPath}/reco"
     data-review-api-base="${pageContext.request.contextPath}/recommend-reviews"
     data-preselected-supplements='${fn:escapeXml(selectedSupplementIdsJson)}'>
  <div class="recommend-header">
    <h2>💊 맞춤 영양제 분석</h2>
    <p>먼저 영양제를 고르고 한 번만 분석하면, 마지막에 결과를 3가지로 나눠서 보여드려요.</p>
  </div>

  <div class="selection-stage">
    <div class="selection-overview">
      <div class="selection-copy">
        <span class="selection-badge">STEP 1</span>
        <strong><span data-selected-count>0</span>개 선택됨</strong>
        <p id="selectionGuideText">대표 영양제를 먼저 보고, 필요하면 더보기를 눌러 전체 목록을 펼치세요.</p>
      </div>
      <div class="selection-pill">
        <span>분석 완료 후</span>
        <strong>좋은 조합 · 추가 추천 · 주의/복용시간</strong>
      </div>
    </div>

    <div class="supp-selection">
      <h3>어떤 영양제를 드시고 계신가요? (다중 선택)</h3>
      <p class="supp-selection-note">대표 영양제를 먼저 확인하고, 더 필요한 경우 전체 영양제를 펼쳐서 선택하세요.</p>

      <div class="supp-grid">
        <c:forEach var="supp" items="${featuredSupplements}">
          <label class="supp-option">
            <input type="checkbox"
                   name="supp"
                   value="${supp.supplementId}"
                   data-review-key="${supp.supplementName}">
            <div class="supp-option-copy">
              <span class="supp-option-name">${supp.supplementName}</span>
              <small>${not empty supp.supplementTiming ? supp.supplementTiming : '복용 정보 준비 중'}</small>
            </div>
          </label>
        </c:forEach>
      </div>

      <c:if test="${not empty moreSupplements}">
        <div class="supp-grid supp-grid-more" id="moreSupplements">
          <c:forEach var="supp" items="${moreSupplements}">
            <label class="supp-option">
              <input type="checkbox"
                     name="supp"
                     value="${supp.supplementId}"
                     data-review-key="${supp.supplementName}">
              <div class="supp-option-copy">
                <span class="supp-option-name">${supp.supplementName}</span>
                <small>${not empty supp.supplementTiming ? supp.supplementTiming : '복용 정보 준비 중'}</small>
              </div>
            </label>
          </c:forEach>
        </div>

        <button type="button" class="more-supp-btn" id="toggleMoreSupps" onclick="toggleMoreSupplements()">
          전체 영양제 보기
        </button>
      </c:if>
    </div>

    <div class="selection-actions">
      <button class="btn btn-primary btn-full analyze-btn" id="analyzeBtn" onclick="executeAnalysis()" disabled>
        🔍 선택한 영양제 <span data-selected-count>0</span>개 분석하기
      </button>
      <button type="button" class="reset-selection-btn" onclick="resetSupplementSelection()">
        선택 초기화
      </button>
    </div>
  </div>

  <div id="analysisResult" class="analysis-result-wrap" style="display: none;"></div>

  <div class="best-reviews-section" id="bestReviewsSection" style="display: none;">
    <h3>⭐ 찐 유저들의 베스트 리뷰</h3>
    <p class="review-section-copy">실제 사용자들의 생생한 후기를 확인해보세요.</p>
    <div id="bestReviewList" class="review-grid">
      <div class="loading-spinner">리뷰를 불러오는 중입니다...</div>
    </div>
  </div>
</div>
<script src="${pageContext.request.contextPath}/js/recommend.js?v=<%=System.currentTimeMillis()%>"></script>
