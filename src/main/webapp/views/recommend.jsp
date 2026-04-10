  <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <div class="recommend-container">
    <div class="recommend-header">
      <h2>💊 맞춤 영양제 분석</h2>
      <p>현재 먹고 있는 영양제를 선택하고 분석해 보세요!</p>
    </div>

    <div class="analysis-tabs">
      <button class="tab-btn active" onclick="setAnalysisType('my', this)">
        1️⃣ 내 영양제 분석<br><small>(조합/시간)</small>
      </button>
      <button class="tab-btn" onclick="setAnalysisType('deficiency', this)">
        2️⃣ 부족한 영양소<br><small>(맞춤 추천)</small>
      </button>
      <button class="tab-btn" onclick="setAnalysisType('compatibility', this)">
        3️⃣ 영양제 궁합<br><small>(상성 확인)</small>
      </button>
    </div>

    <div class="supp-selection">
      <h3>어떤 영양제를 드시고 계신가요? (다중 선택)</h3>
      <div class="supp-grid">
        <label><input type="checkbox" name="supp" value="vitC"> 🍋 비타민C</label>
        <label><input type="checkbox" name="supp" value="vitD"> ☀️ 비타민D</label>
        <label><input type="checkbox" name="supp" value="vitB"> ⚡ 비타민B</label>
        <label><input type="checkbox" name="supp" value="omega3"> 🐟 오메가3</label>
        <label><input type="checkbox" name="supp" value="magnesium"> 🌿 마그네슘</label>
        <label><input type="checkbox" name="supp" value="calcium"> 🦴 칼슘</label>
        <label><input type="checkbox" name="supp" value="iron"> 🩸 철분</label>
        <label><input type="checkbox" name="supp" value="zinc"> 🛡️ 아연</label>
        <label><input type="checkbox" name="supp" value="vitA"> 🥕 비타민A</label>
        <label><input type="checkbox" name="supp" value="vitE"> 🌰 비타민E</label>
      </div>
    </div>

    <button class="btn btn-primary btn-full analyze-btn" onclick="executeAnalysis()">
      🔍 선택한 영양제 분석하기
    </button>

    <div id="analysisResult" style="display: none; margin-top: 24px;"></div>

    <hr style="margin: 40px 0; border: 0; border-top: 1px solid #eaeaea;">

    <div class="best-reviews-section">
      <h3>⭐ 찐 유저들의 베스트 리뷰</h3>
      <p style="color: #666; font-size: 14px;">실제 사용자들의 생생한 후기를 확인해보세요.</p>
      <div id="bestReviewList" class="review-grid">
        <div class="loading-spinner">리뷰를 불러오는 중입니다...</div>
      </div>
    </div>
  </div>

  <script>
    let currentAnalysisType = 'my';

    function setAnalysisType(type, btnElement) {
      currentAnalysisType = type;
      document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
      btnElement.classList.add('active');
    }

    function executeAnalysis() {
      if (typeof analyzeSupplements === 'function') {
        analyzeSupplements(currentAnalysisType);
        setTimeout(extractMissingSuppsAndLoadReviews, 300); // 0.3초 대기 후 실행
      }
    }

    document.addEventListener('DOMContentLoaded', () => {
      const urlParams = new URLSearchParams(window.location.search);
      const selectedSupps = urlParams.getAll('supp');

      if (selectedSupps && selectedSupps.length > 0) {
        selectedSupps.forEach(val => {
          const checkbox = document.querySelector(`input[name="supp"][value="\${val}"]`);
          if (checkbox) checkbox.checked = true;
        });
        setTimeout(executeAnalysis, 100);
        window.history.replaceState({}, document.title, "/recommend");
      } else {
        loadBestReviews([], 'false', 3);
      }
    });

    // 🕵️ 화면에서 부족한 영양소 빼와서 개수 분배하기!
    function extractMissingSuppsAndLoadReviews() {
      // 1️⃣ 내 영양제 분석 탭
      if (currentAnalysisType === 'my') {
        const checkedBoxes = document.querySelectorAll('input[name="supp"]:checked');
        const checkedSupps = Array.from(checkedBoxes).map(cb => cb.value);
        loadBestReviews(checkedSupps, 'false', 3);
        return;
      }

      // 2️⃣ 부족한 영양소 탭
      if (currentAnalysisType === 'deficiency') {
        const resultHtml = document.getElementById('analysisResult').innerHTML;
        const missingSupps = [];
        const allSuppKeywords = {
          "비타민C": "vitC", "비타민 C": "vitC", "비타민D": "vitD", "비타민 D": "vitD",
          "비타민B": "vitB", "비타민 B": "vitB", "비타민A": "vitA", "비타민 A": "vitA",
          "비타민E": "vitE", "비타민 E": "vitE", "오메가3": "omega3", "오메가 3": "omega3",
          "마그네슘": "magnesium", "칼슘": "calcium", "철분": "iron", "아연": "zinc"
        };

        for (const [koreanName, englishCode] of Object.entries(allSuppKeywords)) {
          if (resultHtml.includes(koreanName)) {
            if (!missingSupps.includes(englishCode)) missingSupps.push(englishCode);
          }
        }

        // 🌟 팀장님 지시사항: 개수 분배 로직
        let limitPerSupp = 1;
        const count = missingSupps.length;
        if (count >= 4) limitPerSupp = 1;
        else if (count === 3) limitPerSupp = 2;
        else if (count === 2) limitPerSupp = 2;
        else if (count === 1) limitPerSupp = 4;

        loadBestReviews(missingSupps, 'true', limitPerSupp);
      }
    }

    // 🌟 리뷰 서버에 요청하기
    function loadBestReviews(suppsArray, isDeficiency, limitPerSupp) {
      let fetchUrl = `recommend-reviews?isDef=\${isDeficiency}&limit=\${limitPerSupp}`;

      if (suppsArray && suppsArray.length > 0) {
        const queryString = suppsArray.map(val => 'supp=' + val).join('&');
        fetchUrl += '&' + queryString;
      }

      fetch(fetchUrl, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
              .then(res => res.json())
              .then(data => {
                const reviewBox = document.getElementById('bestReviewList');
                const titleArea = document.querySelector('.best-reviews-section h3');

                // 타이틀 변경
                if (isDeficiency === 'true' && suppsArray.length > 0) {
                  titleArea.innerHTML = '⭐ 추천 영양제 베스트 리뷰';
                } else {
                  titleArea.innerHTML = '⭐ 내 영양제 관련 베스트 리뷰';
                }

                if (!data || data.length === 0) {
                  reviewBox.innerHTML = '<div style="padding:40px; text-align:center; color:#777; background:#f9f9f9; border-radius:12px;">관련된 찐 리뷰가 아직 없습니다 🥲</div>';
                  return;
                }

                reviewBox.innerHTML = data.map(r => `
            <div class="review-card" style="padding: 20px; border: 1px solid #eee; border-radius: 12px; margin-bottom: 15px;">
                <div class="rc-header" style="display: flex; justify-content: space-between; margin-bottom: 12px;">
                    <span class="rc-supp" style="font-weight: 800; color: #6a8d3a; background: #f0f5e5; padding: 4px 10px; border-radius: 20px; font-size: 0.9em;">💊 \${r.supp_name || '영양제'}</span>
                    <span class="rc-stars" style="color: #f1c40f; letter-spacing: 2px;">\${'★'.repeat(r.r_score)}\${'☆'.repeat(5 - r.r_score)}</span>
                </div>
                <p class="rc-text" style="font-size: 15px; line-height: 1.6; color: #444;">"\${r.r_content}"</p>
                <div class="rc-user" style="text-align: right; color: #999; font-size: 13px; font-weight: bold; margin-top: 10px;">- \${r.user_id.substring(0,3)}*** 님</div>
            </div>
        `).join('');
              });
    }
  </script>
  </script>