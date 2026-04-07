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
  // 현재 선택된 분석 타입 (기본값: my)
  let currentAnalysisType = 'my';

  // 탭 변경 함수
  function setAnalysisType(type, btnElement) {
    currentAnalysisType = type;
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    btnElement.classList.add('active');
  }

  // app.js에 있는 분석 함수 호출
  function executeAnalysis() {
    if (typeof analyzeSupplements === 'function') {
      analyzeSupplements(currentAnalysisType);
    } else {
      console.error("app.js의 analyzeSupplements 함수를 찾을 수 없습니다.");
    }
  }

  // 화면이 켜지자마자 실행되는 부분 (여기가 핵심입니다!)
  document.addEventListener('DOMContentLoaded', () => {

    // 1. 주소창(URL)에서 메인 화면이 보낸 영양제 데이터 꺼내기
    const urlParams = new URLSearchParams(window.location.search);
    const selectedSupps = urlParams.getAll('supp'); // 예: ['vitD', 'omega3', 'zinc', 'iron']

    // 2. 만약 주소창에 영양제 데이터가 있다면?
    if (selectedSupps && selectedSupps.length > 0) {

      // ① 해당 영양제 체크박스들 자동으로 V 체크하기
      selectedSupps.forEach(val => {
        const checkbox = document.querySelector(`input[name="supp"][value="\${val}"]`);
        if (checkbox) {
          checkbox.checked = true;
        }
      });

      // ② 사용자가 굳이 '분석하기' 버튼을 누르지 않아도 자동으로 분석 실행!
      // 체크박스 체크되는 시간차를 고려해 0.1초 뒤에 실행합니다.
      setTimeout(() => {
        executeAnalysis();
      }, 100);

      // ③ 주소창이 너무 길면 지저분하니까 깔끔하게 /recommend 로 정리 (선택사항)
      window.history.replaceState({}, document.title, "/recommend");
    }

    // (기존) 베스트 리뷰 불러오기
    loadBestReviews();
  });

  // 베스트 리뷰 비동기 로드 함수
  function loadBestReviews() {
    setTimeout(() => {
      const dummyReviews = [
        { supp: "마그네슘", rating: 5, user: "김*루", text: "밤에 잠이 진짜 잘 와요! 피로가 싹 가시는 기분입니다." },
        { supp: "오메가3", rating: 4, user: "이*트", text: "알약 크기가 적당하고 비린내가 안 나서 먹기 편해요." },
        { supp: "비타민C", rating: 5, user: "박*제", text: "아침에 일어날 때 확실히 덜 피곤해요. 강력 추천 💪" }
      ];

      const reviewBox = document.getElementById('bestReviewList');
      if(reviewBox) {
        reviewBox.innerHTML = dummyReviews.map(r => `
                    <div class="review-card">
                        <div class="rc-header">
                            <span class="rc-supp">💊 \${r.supp}</span>
                            <span class="rc-stars">\${'⭐'.repeat(r.rating)}</span>
                        </div>
                        <p class="rc-text">"\${r.text}"</p>
                        <span class="rc-user">- \${r.user} 님</span>
                    </div>
                `).join('');
      }
    }, 800);
  }
</script>