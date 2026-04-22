let PER_PAGE = 8;
const SUPPLEMENT_IMAGE_BASE = '/supplementImg/supplementImgFile/';
const SUPPLEMENT_DEFAULT_IMAGE = SUPPLEMENT_IMAGE_BASE + 'default.png';

const logined = (typeof IS_LOGIN !== 'undefined' && IS_LOGIN === true);
// const isLogin = (window.IS_LOGIN === true);
// DB의 body_id와 매핑 ? body 테이블 기준으로 전부 수정
const PARTS = {
    hair: {label: '머리카락', color: '#9333EA', text: '#581C87', body_id: 1},
    skin: {label: '피부', color: '#EF4444', text: '#7F1D1D', body_id: 2},
    eye: {label: '눈', color: '#2563EB', text: '#1E3A8A', body_id: 3},
    brain: {label: '뇌', color: '#EC4899', text: '#831843', body_id: 4},
    lung: {label: '폐', color: '#3B82F6', text: '#1E3A8A', body_id: 5},
    heart: {label: '심장', color: '#DC2626', text: '#7F1D1D', body_id: 6},
    liver: {label: '간', color: '#10B981', text: '#065F46', body_id: 7},
    stomach: {label: '위', color: '#F59E0B', text: '#78350F', body_id: 8},
    intestine: {label: '장', color: '#7C3AED', text: '#4C1D95', body_id: 9},
    bone: {label: '뼈', color: '#64748B', text: '#1E293B', body_id: 10},
    muscle: {label: '근육', color: '#EF4444', text: '#7F1D1D', body_id: 11},
};
console.log('한글 나오니~~?')

let likedLoaded = false;
let selected = new Set();   // 선택된 part key들
let likedIds = new Set();   // 좋아요한 supplementId들
let suppCache = {};         // { partKey: [BodyDTO, ...] } 캐시
let sort = 'recent';
let page = 1;
let modalId = null;
let allMode = false;
const isAdmin = (window.IS_ADMIN === true);
let adminModeOn = false;
console.log("is admin? => " + isAdmin);
console.log(likedIds)

function getSupplementImageSrc(path) {
    if (!path) return SUPPLEMENT_DEFAULT_IMAGE;

    const normalized = String(path).trim();
    if (!normalized) return SUPPLEMENT_DEFAULT_IMAGE;
    if (/^(https?:)?\/\//i.test(normalized)) return normalized;
    if (normalized.startsWith('/')) return normalized;
    if (normalized.includes('/')) return '/' + normalized.replace(/^\/+/, '');
    return SUPPLEMENT_IMAGE_BASE + normalized;
}

// 로그인한 id로 좋아요 한것들 likedIds에 setting
async function setLikedIds() {
    if (likedLoaded) return;   // 🔥 추가

    await fetch('/body?action=liked')
        .then(res => res.json())
        .then(data => {
            likedIds = new Set(data);
            likedLoaded = true;   // 🔥 추가
        });

}

// ── 체크박스 렌더링 ──
function buildCheckboxes() {
    const g = document.getElementById('cb-grid');
    Object.entries(PARTS).forEach(([k, v]) => {
        const d = document.createElement('div');
        d.className = 'cb-item';
        d.dataset.part = k;
        d.style.color = v.color;
        d.innerHTML = `
      <div class="cb-box" id="cbbox-${k}">
        <div class="cb-check" id="cbcheck-${k}" style="background:${v.color}"></div>
      </div>
      <span>${v.label}</span>`;
        d.onclick = () => togglePart(k);
        g.appendChild(d);
    });
}

// ── 부위 토글 ──
function togglePart(k) {
    if (selected.has(k)) {
        selected.delete(k);
    } else {
        selected.add(k);
    }
    allMode = false;
    syncCheckboxUI();

    // 캐시에 없는 부위만 fetch
    const missingParts = [...selected].filter(p => !suppCache[p] && PARTS[p].body_id);
    if (missingParts.length === 0) {
        renderList();
        return;
    }
    Promise.all(missingParts.map(p => fetchSupps(p)))
        .then(() => renderList());
}

// ── 서버에서 영양제 데이터 가져오기 ──
function fetchSupps(partKey) {
    const bodyId = PARTS[partKey].body_id;
    if (!bodyId) {
        suppCache[partKey] = [];
        return Promise.resolve();
    }

    return fetch(`/body?action=supps&bodyId=${bodyId}&sort=${sort}`)
        .then(r => r.json())
        .then(data => {
            // 서버 BodyDTO 필드명 그대로 사용
            suppCache[partKey] = data.map(s => ({
                id: s.supplementId,
                name: s.supplementName,
                efficacy: s.supplementEfficacy,
                dosage: s.supplementDosage,
                timing: s.supplementTiming,
                caution: s.supplementCaution,
                imgPath: s.supplementImagePath,
                views: s.supplementViewCount,
                likes: s.likeCount,
                part: partKey
            }));
        })
        .catch(() => {
            suppCache[partKey] = [];
        });
}

// ── 좋아요 토글 (서버 연동) ──
// ? 수정: alert 대신 로그인 모달 표시
function toggleLike(id) {
    if (!logined) {
        showLoginModal(); // 로그인 모달 띄우기
        return;
    }
    fetch(`/body?action=like&suppId=${id}`, {method: 'POST'})
        .then(r => r.json())
        .then(data => {
            if (data.liked) likedIds.add(id); else likedIds.delete(id);
            for (const p in suppCache) {
                const s = suppCache[p].find(x => x.id === id);
                if (s) {
                    // 서버에서 totalLikes를 주면 그걸 쓰고, 없으면 1씩 계산
                    s.likes = data.totalLikes || (s.likes + (data.liked ? 1 : -1));
                }
            }
            renderList();
            if (modalId === id) refreshModal(id);
        });
}

// ? 추가: 로그인 유도 모달 함수
function showLoginModal() {
    const existing = document.getElementById('login-modal-overlay');
    if (existing) existing.remove();

    const overlay = document.createElement('div');
    overlay.id = 'login-modal-overlay';
    overlay.style.cssText = `
        position: fixed;
        inset: 0;
        background: rgba(0,0,0,0.45);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000;
        padding: 16px;
    `;
    overlay.onclick = (e) => {
        if (e.target === overlay) closeLoginModal();
    };

    overlay.innerHTML = `
      <div class="login-modal-box" onclick="event.stopPropagation()">
        <p class="login-modal-title">로그인이 필요합니다</p>
        <p class="login-modal-desc">좋아요 기능은 로그인 후 이용 가능합니다.</p>
        <div style="display:flex; gap:8px; justify-content:center;">
          <button class="login-modal-btn-login"
            onclick="location.href='user-Login?redirect=' + encodeURIComponent(location.pathname + location.search)">
            로그인하기
          </button>
          <button class="login-modal-btn-close" onclick="closeLoginModal()">닫기</button>
        </div>
      </div>`;

    document.body.appendChild(overlay);
}

// 닫기 함수도 함께 수정
function closeLoginModal() {
    const overlay = document.getElementById('login-modal-overlay');
    if (overlay) overlay.remove();
}

// ── 모아보기 ──
function collectAll() {
    allMode = true;
    page = 1;
    console.log('너는 한글 나오니~~')
    // 1. 모든 PARTS의 키를 selected Set에 추가 (이게 핵심!)
    selected.clear();
    Object.keys(PARTS).forEach(k => {

        // console.log(k);
        selected.add(k)
    });

    // 2. 체크박스 및 SVG UI 갱신
    syncCheckboxUI();

    // ALL 버튼 파란색으로 ? 초기화 버튼은 원래대로
    document.querySelectorAll('.cb-btn').forEach(b => b.classList.remove('on'));
    const allBtn = document.querySelector('.cb-btn.primary');
    if (allBtn) allBtn.classList.add('on');

    const missing = Object.keys(PARTS).filter(p => !suppCache[p] && PARTS[p].body_id);
    if (missing.length === 0) {
        renderList();
        return;
    }
    document.getElementById('list-area').innerHTML = '<p class="empty-msg">불러오는 중...</p>';
    Promise.all(missing.map(p => fetchSupps(p))).then(() => renderList());
}

function resetAll() {
    selected.clear();
    allMode = false;
    page = 1;
    syncCheckboxUI();

    // ALL 버튼 파란색 제거
    const allBtn = document.querySelector('.cb-btn.primary');
    if (allBtn) allBtn.classList.remove('on');

    renderList();
}

function setSort(s, btn) {
    sort = s;
    page = 1;
    suppCache = {}; // 캐시 초기화

    document.querySelectorAll('.sort-btn').forEach(b => b.classList.remove('on'));
    btn.classList.add('on');

    // ✅ allMode 여부에 따라 대상 부위를 다르게 결정
    const targetParts = allMode
        ? Object.keys(PARTS).filter(p => PARTS[p].body_id)   // 전체 부위
        : [...selected].filter(p => PARTS[p].body_id);        // 선택된 부위만

    if (targetParts.length === 0) {
        renderList();
        return;
    }

    // ✅ allMode일 때 로딩 메시지 표시
    if (allMode) {
        document.getElementById('list-area').innerHTML = '<p class="empty-msg">불러오는 중...</p>';
    }

    Promise.all(targetParts.map(p => fetchSupps(p))).then(() => renderList());
}

function goPage(p) {
    const all = getSortedList();
    const tp = Math.max(1, Math.ceil(all.length / PER_PAGE));
    if (p < 1 || p > tp) return;
    page = p;
    renderList();
}

// ── 현재 선택 기준 합산 + 정렬 ──
function getSortedList() {
    const parts = allMode ? new Set(Object.keys(PARTS)) : selected;
    let arr = [];
    parts.forEach(p => {
        if (suppCache[p]) arr = arr.concat(suppCache[p]);
    });
    const seen = new Set();
    arr = arr.filter(s => {
        if (seen.has(s.id)) return false;
        seen.add(s.id);
        return true;
    });
    if (sort === 'view') return arr.sort((a, b) => b.views - a.views);
    if (sort === 'like') return arr.sort((a, b) => b.likes - a.likes); // ✅ 단순 비교
    return arr.sort((a, b) => b.id - a.id);
}

// ── 리스트 렌더링 ──
async function renderList() {
    if (logined) await setLikedIds();
    // console.log(likedIds)
    const la = document.getElementById('list-area');
    const pa = document.getElementById('paging-area');
    const ta = document.getElementById('tag-area');
    const pt = document.getElementById('panel-title');
    ta.innerHTML = '';

    if (!allMode && selected.size === 0) {
        pt.textContent = '부위를 선택하세요';
        la.innerHTML = '<p class="empty-msg">신체 부위를 선택하면 영양제 목록이 나타납니다.</p>';
        pa.innerHTML = '';
        return;
    }

    const showParts = allMode ? new Set(Object.keys(PARTS)) : selected;
    showParts.forEach(p => {
        const t = document.createElement('span');
        t.className = 'tag';
        t.textContent = PARTS[p].label;
        t.style.borderColor = PARTS[p].color;
        t.style.color = PARTS[p].color;
        ta.appendChild(t);
    });

    const all = getSortedList();
    // console.log(all)
    const total = all.length;
    const totalPages = Math.max(1, Math.ceil(total / PER_PAGE));
    if (page > totalPages) page = 1;

    pt.textContent = (allMode ? '전체' : '선택 부위') + ` 영양제 (${total}개)`;

    if (total === 0) {
        la.innerHTML = '<p class="empty-msg">등록된 영양제가 없습니다.</p>';
        pa.innerHTML = '';
        return;
    }

    const slice = all.slice((page - 1) * PER_PAGE, page * PER_PAGE);
    la.innerHTML = '<div class="grid">' + slice.map(s => `
    <div class="card" onclick="openModal(${s.id})">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:3px">
        <span class="card-name">${s.name}</span>
        <span style="font-size:9px;padding:1px 5px;border-radius:20px;
          background:${PARTS[s.part].color}22;color:${PARTS[s.part].text};
          border:1px solid ${PARTS[s.part].color}55;flex-shrink:0;margin-left:4px">
          ${PARTS[s.part].label}
        </span>
      </div>
      <div class="card-eff">${s.efficacy}</div>
      <div class="card-foot">
        <span class="card-stats">&#128065; ${s.views} · &#9829; ${s.likes}</span>
        ${!isAdmin ? `
        <button class="like-btn ${likedIds.has(s.id) ? 'on' : ''}"
          onclick="event.stopPropagation();toggleLike(${s.id})">
          ${likedIds.has(s.id) ? '&#9829; 취소' : '&#9825; 좋아요'}
        </button> ` : ''}
      </div>
      ${adminModeOn && isAdmin ? `
      <div class="admin-card-btn-wrap" onclick="event.stopPropagation()">
        <button class="admin-card-btn-edit"
          onclick="openAdminModal('update',${s.id})">수정</button>
        <button class="admin-card-btn-del"
          onclick="deleteSupp(${s.id},'${s.name.replace(/'/g, "\\'")}')">삭제</button>
      </div>` : ''}
    </div>`).join('') + '</div>';

    // 페이징
    if (totalPages > 1) {
        let pg = `<div class="paging">`;
        pg += `<button class="pg-btn" onclick="goPage(${page - 1})" ${page === 1 ? 'disabled' : ''}>&#8249;</button>`;
        for (let i = 1; i <= totalPages; i++) {
            pg += `<button class="pg-btn ${i === page ? 'on' : ''}" onclick="goPage(${i})">${i}</button>`;
        }
        pg += `<button class="pg-btn" onclick="goPage(${page + 1})" ${page === totalPages ? 'disabled' : ''}>&#8250;</button>`;
        pg += `</div>`;
        pa.innerHTML = pg;
    } else {
        pa.innerHTML = '';
    }
}

// ── 모달 ──
function openModal(id) {
    modalId = id;

    // 조회수 증가 fetch
    fetch(`/body?action=detail&suppId=${id}`)
        .then(r => r.json())
        .then(data => {
            for (const p in suppCache) {
                const s = suppCache[p].find(x => x.id === id);
                if (s) s.views = data.supplementViewCount;
            }
            refreshModal(id);
            renderList(); // ✅ 이 한 줄 추가 - 리스트 카드 조회수도 갱신
        })
        .catch(() => refreshModal(id));

    refreshModal(id); // 즉시 한 번 띄움
}

function refreshModal(id) {
    let s = null;
    for (const p in suppCache) {
        s = suppCache[p].find(x => x.id === id);
        if (s) break;
    }
    if (!s) return;

    const on = likedIds.has(id);
    const pt = PARTS[s.part];

    const existing = document.getElementById('supp-modal-overlay');
    if (existing) existing.remove();

    const overlay = document.createElement('div');
    overlay.id = 'supp-modal-overlay';
    overlay.style.cssText = `
        position: fixed;
        inset: 0;
        background: rgba(0,0,0,0.45);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        padding: 16px;
    `;
    overlay.onclick = (e) => {
        if (e.target === overlay) closeModal();
    };

    const imgHtml = s.imgPath
        ? `<img src="${getSupplementImageSrc(s.imgPath)}" style="width:52px;height:52px;border-radius:10px;object-fit:cover;"
               onerror="this.onerror=null;this.src='${SUPPLEMENT_DEFAULT_IMAGE}';">`
        : `<div style="width:52px;height:52px;border-radius:10px;
               background:${pt.color}22;display:flex;align-items:center;
               justify-content:center;font-size:22px;">💊</div>`;

    overlay.innerHTML = `
      <div class="supp-modal-box">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:14px;">
          ${imgHtml}
          <div>
            <div class="supp-modal-name">${s.name}</div>
            <span style="font-size:10px;padding:2px 8px;border-radius:20px;
                         background:${pt.color}22;color:${pt.text};
                         border:1px solid ${pt.color}55;display:inline-block;margin-top:3px;">
              ${pt.label}
            </span>
          </div>
        </div>
        <div style="display:flex;gap:8px;margin-bottom:7px;">
          <span class="supp-modal-lbl">효능</span>
          <span class="supp-modal-val">${s.efficacy}</span>
        </div>
        <div style="display:flex;gap:8px;margin-bottom:7px;">
          <span class="supp-modal-lbl">복용량</span>
          <span class="supp-modal-val">${s.dosage || '-'}</span>
        </div>
        <div style="display:flex;gap:8px;margin-bottom:7px;">
          <span class="supp-modal-lbl">복용 시기</span>
          <span class="supp-modal-val">${s.timing || '-'}</span>
        </div>
        <div class="supp-modal-caution">⚠ ${s.caution || '해당 없음'}</div>
        <div class="supp-modal-foot">
          <span class="supp-modal-stats">👁 ${s.views} &nbsp; ♥ ${s.likes + (on ? 1 : 0)}</span>
          <div style="display:flex;gap:8px;">
            ${!isAdmin ? `
            <button class="supp-modal-btn-like ${on ? 'on' : ''}"
              onclick="toggleLike(${id})">
              ${on ? '♥ 취소' : '♡ 좋아요'}
            </button>` : ''}
            <button class="supp-modal-btn-close" onclick="closeModal()">닫기</button>
          </div>
        </div>
      </div>`;

    document.body.appendChild(overlay);
}

function closeModal() {
    const overlay = document.getElementById('supp-modal-overlay');
    if (overlay) overlay.remove();
    modalId = null;
}

function syncCheckboxUI() {
    Object.keys(PARTS).forEach(k => {
        // allMode가 true이거나 selected에 포함되어 있으면 체크 표시
        const on = allMode || selected.has(k);
        const box = document.getElementById('cbbox-' + k);
        const chk = document.getElementById('cbcheck-' + k);
        if (box) box.classList.toggle('on', on);
        if (chk) chk.classList.toggle('show', on);
        const item = document.querySelector(`.cb-item[data-part="${k}"]`);
        if (item) item.classList.toggle('checked', on);
        document.querySelectorAll(`.body-part[data-part="${k}"]`).forEach(el => el.classList.toggle('active', on));
    });
}

// SVG 클릭 이벤트
// DOMContentLoaded로 감싸서 DOM 준비 후 실행 보장
document.addEventListener('DOMContentLoaded', function () {

    // 체크박스 렌더링
    buildCheckboxes();

    // SVG 클릭 이벤트 등록
    document.querySelectorAll('.body-part').forEach(el => {
        el.addEventListener('click', () => {
            const p = el.dataset.part;
            if (p) {
                allMode = false;
                togglePart(p);
            }
        });
    });

    /* =========================================================
       관리자 모드 ? body_view 화면 인라인 CRUD
       ========================================================= */
});

// ── 관리 모드 ON/OFF 토글 ──
function toggleAdminMode() {
    adminModeOn = !adminModeOn;
    const toggleBtn = document.getElementById('adminToggleBtn');
    const addBtn = document.getElementById('adminAddBtn');

    if (adminModeOn) {
        toggleBtn.textContent = '관리 모드';
        toggleBtn.style.background = '#f95c8d';
        toggleBtn.style.color = '#ffffff';
    } else {
        toggleBtn.textContent = '관리 모드';
        toggleBtn.style.background = '#FF9800';
    }

    // 추가 버튼 표시/숨김
    if (addBtn) addBtn.style.display = adminModeOn ? 'inline-block' : 'none';

    // 카드 다시 렌더해서 수정/삭제 버튼 표시 반영
    renderList();
}

// ── 관리자 모달 열기 ──
// mode: 'insert' | 'update'
// 관리자 모달 열기
function openAdminModal(mode, suppId) {

    // 🔥 이거 추가 (혹시 모를 submit 방지)
    if (window.event) event.preventDefault();

    const overlay = document.getElementById('adminModalOverlay');
    if (!overlay) return;

    overlay.style.display = 'flex'; // flex로 설정해야 정중앙 정렬됨
    document.body.classList.add('modal-open'); // 배경 스크롤 차단 및 레이아웃 보호

    // 기존 데이터 초기화 및 모드 설정
    document.getElementById('adminAction').value = mode;
    document.getElementById('adminSuppId').value = suppId || '';

    if (mode === 'update') {
        document.getElementById('adminModalTitle').textContent = '영양소 수정';

        // 👉 수정 데이터 불러오기
        fetch(`admin?action=getOne&suppId=${suppId}`)
            .then(res => res.json())
            .then(res => {
                if (!res.success) {
                    alert(res.message);
                    return;
                }

                const data = res.data; // 🔥 핵심

                document.getElementById('adminName').value = data.supplementName || '';
                document.getElementById('adminEfficacy').value = data.supplementEfficacy || '';
                document.getElementById('adminDosage').value = data.supplementDosage || '';
                document.getElementById('adminTiming').value = data.supplementTiming || '';
                document.getElementById('adminCaution').value = data.supplementCaution || '';
                document.getElementById('adminImgPath').value = data.supplementImagePath || '';
            });


        // fetch 데이터 로드 로직...
    } else {
        document.getElementById('adminModalTitle').textContent = '새 영양소 등록';

        // 👉 초기화
        document.getElementById('adminName').value = '';
        document.getElementById('adminEfficacy').value = '';
        document.getElementById('adminDosage').value = '';
        document.getElementById('adminTiming').value = '';
        document.getElementById('adminCaution').value = '';
        document.getElementById('adminImgPath').value = '';
        // input 초기화 로직...
    }
}

// 관리자 모달 닫기
function closeAdminModal() {
    const overlay = document.getElementById('adminModalOverlay');
    if (overlay) {
        overlay.style.display = 'none';
        document.body.classList.remove('modal-open'); // 배경 스크롤 복구
    }
}

// ── 저장 버튼 (insert / update AJAX) ──
// [수정 전] fetch('/api/admin', { ... body: JSON.stringify(...) })
// [수정 후]
function submitAdminModal(button) {
    const action = document.getElementById('adminAction').value;
    const suppId = document.getElementById('adminSuppId').value;

    // 🔥 전송할 데이터를 객체로 생성
    const payload = {
        action: action,
        suppId: suppId,
        supplementName: document.getElementById('adminName').value.trim(),
        supplementEfficacy: document.getElementById('adminEfficacy').value.trim(),
        supplementDosage: document.getElementById('adminDosage').value.trim(),
        supplementTiming: document.getElementById('adminTiming').value.trim(),
        supplementCaution: document.getElementById('adminCaution').value.trim(),
        supplementImagePath: document.getElementById('adminImgPath').value.trim(),
        bodyId: document.getElementById('adminBodyId') ? document.getElementById('adminBodyId').value : ''
    };

    const request = () => fetch('/admin', { // URL 확인 필요 (AdminC 매핑 경로)
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(payload)
    })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                alert(data.message);
                location.reload();
            } else {
                alert(data.message);
            }
        })
        .catch(err => alert("오류 발생: " + err));

    if (window.GrootSubmitGuard?.runWithActionLock) {
        return window.GrootSubmitGuard.runWithActionLock(
            button || document.querySelector('#adminModalOverlay button[onclick^="submitAdminModal"]'),
            request,
            {pendingText: action === 'update' ? '수정 중...' : '저장 중...'}
        );
    }
    return request();
}

// ── 삭제 AJAX ──
function deleteSupp(suppId, suppName) {
    if (!confirm(`"${suppName}"을(를) 삭제하시겠습니까?`)) return;

    fetch('/admin', {
        method: 'POST',
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: JSON.stringify({action: 'delete', suppId: suppId})
    })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                // 캐시에서 해당 영양소 제거 후 리스트 다시 렌더
                for (const p in suppCache) {
                    suppCache[p] = suppCache[p].filter(x => x.id !== suppId);
                }
                closeModal();   // 혹시 모달이 열려있으면 닫기
                renderList();
            } else {
                alert(data.message);
            }
        })
        .catch(err => alert('오류: ' + err));
}

// buildCheckboxes();
