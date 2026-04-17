(function () {
    const root = document.getElementById('recommendPage');
    if (!root || root.dataset.jsInitialized === 'true') {
        return;
    }
    root.dataset.jsInitialized = 'true';

    const recoBasePath = root.dataset.recoBasePath || '';
    const reviewApiBase = root.dataset.reviewApiBase || 'recommend-reviews';
    const preselectedSupplements = parseJsonArray(root.dataset.preselectedSupplements);

    function parseJsonArray(rawValue) {
        try {
            const parsed = JSON.parse(rawValue || '[]');
            return Array.isArray(parsed) ? parsed : [];
        } catch (e) {
            return [];
        }
    }

    function escapeHtml(value) {
        return String(value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function getSupplementInputs() {
        return Array.from(root.querySelectorAll('input[name="supp"]'));
    }

    function getCheckedInputs() {
        return getSupplementInputs().filter(input => input.checked);
    }

    function toggleMoreSupplements() {
        const moreBox = document.getElementById('moreSupplements');
        const toggleBtn = document.getElementById('toggleMoreSupps');
        if (!moreBox || !toggleBtn) {
            return;
        }

        const opened = moreBox.classList.toggle('open');
        toggleBtn.textContent = opened ? '전체 영양제 접기' : '전체 영양제 보기';
    }

    function updateSelectionState() {
        const checkedBoxes = getCheckedInputs();
        const count = checkedBoxes.length;
        const selectedNames = checkedBoxes.map(input => input.dataset.reviewKey).filter(Boolean);
        const countLabels = document.querySelectorAll('[data-selected-count]');
        const analyzeBtn = document.getElementById('analyzeBtn');
        const guideText = document.getElementById('selectionGuideText');

        countLabels.forEach(label => {
            label.textContent = count;
        });

        if (analyzeBtn) {
            analyzeBtn.disabled = count === 0;
        }

        if (!guideText) {
            return;
        }

        if (count === 0) {
            guideText.textContent = '대표 영양제를 먼저 보고, 필요하면 더보기를 눌러 전체 목록을 펼치세요.';
            return;
        }

        const previewNames = selectedNames.slice(0, 3).join(', ');
        const extraText = count > 3 ? ' 외 ' + (count - 3) + '개' : '';
        guideText.textContent = '선택한 영양제: ' + previewNames + extraText;
    }

    function executeAnalysis() {
        if (typeof window.analyzeSupplements === 'function') {
            window.analyzeSupplements('my');
        }
    }

    function resetSupplementSelection() {
        getCheckedInputs().forEach(input => {
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
        return getCheckedInputs()
            .map(input => input.dataset.reviewKey)
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

    function renderReviewCard(review) {
        const score = Math.max(0, Math.min(5, Number(review.r_score) || 0));
        const suppName = escapeHtml(review.supp_name || '영양제');
        const reviewText = escapeHtml(review.r_content || '리뷰 내용이 아직 없어요.');
        const userName = escapeHtml(
            typeof review.user_id === 'string' && review.user_id
                ? review.user_id.substring(0, 3) + '***'
                : '익명'
        );

        return '<div class="review-card">' +
            '<div class="rc-header">' +
            '<span class="rc-supp">💊 ' + suppName + '</span>' +
            '<span class="rc-stars">' + '★'.repeat(score) + '☆'.repeat(5 - score) + '</span>' +
            '</div>' +
            '<p class="rc-text">"' + reviewText + '"</p>' +
            '<div class="rc-user">- ' + userName + ' 님</div>' +
            '</div>';
    }

    function loadBestReviews(suppsArray, limitPerSupp, reviewMode) {
        const reviewBox = document.getElementById('bestReviewList');
        const titleArea = document.querySelector('.best-reviews-section h3');

        if (!reviewBox || !titleArea) {
            return;
        }

        titleArea.innerHTML = reviewMode === 'recommended'
            ? '⭐ 추가 추천 영양제별 베스트 리뷰'
            : '⭐ 선택한 영양제별 베스트 리뷰';

        const uniqueSupps = [...new Set(
            (suppsArray || [])
                .map(value => typeof value === 'string' ? value.trim() : '')
                .filter(Boolean)
        )];

        if (uniqueSupps.length === 0) {
            reviewBox.innerHTML = '<div class="review-empty">관련된 찐 리뷰가 아직 없습니다 🥲</div>';
            return;
        }

        const queryString = uniqueSupps
            .map(value => 'supp=' + encodeURIComponent(value))
            .join('&');
        const fetchUrl = reviewApiBase + '?limit=' + limitPerSupp + '&' + queryString;

        reviewBox.innerHTML = '<div class="loading-spinner">리뷰를 불러오는 중입니다...</div>';

        fetch(fetchUrl, {headers: {'X-Requested-With': 'XMLHttpRequest'}})
            .then(response => {
                if (!response.ok) {
                    throw new Error('Failed to load reviews');
                }
                return response.json();
            })
            .then(data => {
                if (!Array.isArray(data) || data.length === 0) {
                    reviewBox.innerHTML = '<div class="review-empty">관련된 찐 리뷰가 아직 없습니다 🥲</div>';
                    return;
                }

                reviewBox.innerHTML = data.map(renderReviewCard).join('');
            })
            .catch(() => {
                reviewBox.innerHTML = '<div class="review-empty">리뷰를 불러오지 못했어요. 잠시 후 다시 시도해주세요.</div>';
            });
    }

    function refreshReviewSection() {
        if (!window.analysisCompleted) {
            return;
        }

        const reviewSection = document.getElementById('bestReviewsSection');
        const selectedSupps = getCheckedReviewKeys();
        if (reviewSection) {
            reviewSection.style.display = 'block';
        }

        if (window.currentResultTab === 'recommend') {
            const recommendedSupps = getRecommendedReviewKeys();
            const reviewBox = document.getElementById('bestReviewList');
            const titleArea = document.querySelector('.best-reviews-section h3');

            if (titleArea) {
                titleArea.innerHTML = '⭐ 추가 추천 영양제별 베스트 리뷰';
            }

            if (recommendedSupps.length === 0) {
                if (reviewBox) {
                    reviewBox.innerHTML = '<div class="review-empty">추가 추천 영양제 리뷰는 분석 결과가 생기면 여기서 보여드릴게요.</div>';
                }
                return;
            }

            loadBestReviews(recommendedSupps, 1, 'recommended');
            return;
        }

        if (selectedSupps.length === 0) {
            const reviewBox = document.getElementById('bestReviewList');
            const titleArea = document.querySelector('.best-reviews-section h3');
            if (titleArea) {
                titleArea.innerHTML = '⭐ 선택한 영양제별 베스트 리뷰';
            }
            if (reviewBox) {
                reviewBox.innerHTML = '<div class="review-empty">선택한 영양제 리뷰는 영양제를 고르면 여기서 보여드릴게요.</div>';
            }
            return;
        }

        loadBestReviews(selectedSupps, 1, 'selected');
    }

    function applyPreselectedSupplements() {
        if (!preselectedSupplements || preselectedSupplements.length === 0) {
            return false;
        }

        preselectedSupplements.forEach(value => {
            const checkbox = root.querySelector('input[name="supp"][value="' + value + '"]');
            if (checkbox) {
                checkbox.checked = true;
            }
        });

        if (root.querySelector('#moreSupplements input[name="supp"]:checked')) {
            toggleMoreSupplements();
        }

        updateSelectionState();
        setTimeout(executeAnalysis, 100);

        if (recoBasePath) {
            window.history.replaceState({}, document.title, recoBasePath);
        }
        return true;
    }

    function bindEvents() {
        getSupplementInputs().forEach(input => {
            input.addEventListener('change', updateSelectionState);
        });
    }

    window.toggleMoreSupplements = toggleMoreSupplements;
    window.executeAnalysis = executeAnalysis;
    window.resetSupplementSelection = resetSupplementSelection;
    window.refreshReviewSection = refreshReviewSection;
    window.onAnalysisRendered = function () {
        refreshReviewSection();
    };

    bindEvents();
    if (!applyPreselectedSupplements()) {
        updateSelectionState();
    }
})();
