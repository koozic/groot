<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<div class="recommend-container">
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

<script>
  const preselectedSupplements = ${selectedSupplementIdsJson};
  const recoBasePath = '${pageContext.request.contextPath}/reco';

  function toggleMoreSupplements() {
    const moreBox = document.getElementById('moreSupplements');
    const toggleBtn = document.getElementById('toggleMoreSupps');
    if (!moreBox || !toggleBtn) return;

    const opened = moreBox.classList.toggle('open');
    toggleBtn.textContent = opened ? '전체 영양제 접기' : '전체 영양제 보기';
  }

  function updateSelectionState() {
    const checkedBoxes = Array.from(document.querySelectorAll('input[name="supp"]:checked'));
    const count = checkedBoxes.length;
    const selectedNames = checkedBoxes.map(cb => cb.dataset.reviewKey).filter(Boolean);
    const countLabels = document.querySelectorAll('[data-selected-count]');
    const analyzeBtn = document.getElementById('analyzeBtn');
    const guideText = document.getElementById('selectionGuideText');

    countLabels.forEach(label => label.textContent = count);

    if (analyzeBtn) {
      analyzeBtn.disabled = count === 0;
    }

    if (!guideText) return;

    if (count === 0) {
      guideText.textContent = '대표 영양제를 먼저 보고, 필요하면 더보기를 눌러 전체 목록을 펼치세요.';
      return;
    }

    const previewNames = selectedNames.slice(0, 3).join(', ');
    const extraText = count > 3 ? ' 외 ' + (count - 3) + '개' : '';
    guideText.textContent = '선택한 영양제: ' + previewNames + extraText;
  }

  function executeAnalysis() {
    if (typeof analyzeSupplements === 'function') {
      analyzeSupplements('my');
    }
  }

  function resetSupplementSelection() {
    document.querySelectorAll('input[name="supp"]:checked').forEach(input => {
      input.checked = false;
    });

    const moreBox = document.getElementById('moreSupplements');
    const toggleBtn = document.getElementById('toggleMoreSupps');
    const resultBox = document.getElementById('analysisResult');
    const reviewSection = document.getElementById('bestReviewsSection');
    const reviewBox = document.getElementById('bestReviewList');

    if (moreBox) {
      moreBox.classList.remove('open');
    }

    if (toggleBtn) {
      toggleBtn.textContent = '전체 영양제 보기';
    }

    if (resultBox) {
      resultBox.style.display = 'none';
      resultBox.innerHTML = '';
    }

    if (reviewSection) {
      reviewSection.style.display = 'none';
    }

    if (reviewBox) {
      reviewBox.innerHTML = '<div class="loading-spinner">리뷰를 불러오는 중입니다...</div>';
    }

    window.latestAnalysisData = null;
    window.currentResultTab = 'good';
    window.analysisCompleted = false;

    updateSelectionState();
  }

  function getCheckedReviewKeys() {
    return Array.from(document.querySelectorAll('input[name="supp"]:checked'))
      .map(cb => cb.dataset.reviewKey)
      .filter(Boolean);
  }

  function getRecommendedReviewKeys() {
    if (!window.latestAnalysisData || !Array.isArray(window.latestAnalysisData.missing)) {
      return [];
    }

    return window.latestAnalysisData.missing
      .map(item => item.name)
      .filter(Boolean);
  }

  function refreshReviewSection() {
    if (!window.analysisCompleted) {
      return;
    }

    const reviewSection = document.getElementById('bestReviewsSection');
    if (reviewSection) {
      reviewSection.style.display = 'block';
    }

    if (window.currentResultTab === 'recommend') {
      const recommendedSupps = getRecommendedReviewKeys();
      const reviewBox = document.getElementById('bestReviewList');
      const titleArea = document.querySelector('.best-reviews-section h3');
      let limitPerSupp = 1;

      if (titleArea) {
        titleArea.innerHTML = '⭐ 추천 영양제 베스트 리뷰';
      }

      if (recommendedSupps.length === 0) {
        if (reviewBox) {
          reviewBox.innerHTML = '<div class="review-empty">추가 추천 영양제 리뷰는 분석 결과가 생기면 여기서 보여드릴게요.</div>';
        }
        return;
      }

      if (recommendedSupps.length === 3 || recommendedSupps.length === 2) {
        limitPerSupp = 2;
      } else if (recommendedSupps.length === 1) {
        limitPerSupp = 4;
      }

      loadBestReviews(recommendedSupps, 'true', limitPerSupp);
      return;
    }

    loadBestReviews(getCheckedReviewKeys(), 'false', 3);
  }

  function loadBestReviews(suppsArray, isDeficiency, limitPerSupp) {
    let fetchUrl = 'recommend-reviews?isDef=' + isDeficiency + '&limit=' + limitPerSupp;

    if (suppsArray && suppsArray.length > 0) {
      const queryString = suppsArray
        .map(val => 'supp=' + encodeURIComponent(val))
        .join('&');
      fetchUrl += '&' + queryString;
    }

    fetch(fetchUrl, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
      .then(res => res.json())
      .then(data => {
        const reviewBox = document.getElementById('bestReviewList');
        const titleArea = document.querySelector('.best-reviews-section h3');

        if (!reviewBox || !titleArea) return;

        titleArea.innerHTML = (isDeficiency === 'true' && suppsArray.length > 0)
          ? '⭐ 추천 영양제 베스트 리뷰'
          : '⭐ 내 영양제 관련 베스트 리뷰';

        if (!data || data.length === 0) {
          reviewBox.innerHTML = '<div class="review-empty">관련된 찐 리뷰가 아직 없습니다 🥲</div>';
          return;
        }

        reviewBox.innerHTML = data.map(r => `
          <div class="review-card">
            <div class="rc-header">
              <span class="rc-supp">💊 \${r.supp_name || '영양제'}</span>
              <span class="rc-stars">\${'★'.repeat(r.r_score)}\${'☆'.repeat(5 - r.r_score)}</span>
            </div>
            <p class="rc-text">"\${r.r_content}"</p>
            <div class="rc-user">- \${r.user_id.substring(0,3)}*** 님</div>
          </div>
        `).join('');
      });
  }

  window.onAnalysisRendered = function() {
    refreshReviewSection();
  };

  document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('input[name="supp"]').forEach(input => {
      input.addEventListener('change', updateSelectionState);
    });

    if (preselectedSupplements && preselectedSupplements.length > 0) {
      preselectedSupplements.forEach(val => {
        const checkbox = document.querySelector('input[name="supp"][value="' + val + '"]');
        if (checkbox) checkbox.checked = true;
      });

      if (document.querySelector('#moreSupplements input[name="supp"]:checked')) {
        toggleMoreSupplements();
      }

      updateSelectionState();
      setTimeout(executeAnalysis, 100);
      window.history.replaceState({}, document.title, recoBasePath);
      return;
    }

    updateSelectionState();
  });
</script>
