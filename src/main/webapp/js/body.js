const PER_PAGE = 6;

// const isLogin = (typeof IS_LOGIN !== 'undefined' && IS_LOGIN === true);
const isLogin = (window.IS_LOGIN === true);
// DB의 body_id와 매핑 (body 테이블의 실제 ID로 수정)
const PARTS = {
    brain: {label: '뇌', color: '#EC4899', text: '#831843', body_id: null},
    eye: {label: '눈', color: '#2563EB', text: '#1E3A8A', body_id: 1},
    hair: {label: '머리카락', color: '#9333EA', text: '#581C87', body_id: null},
    skin: {label: '피부', color: '#EF4444', text: '#7F1D1D', body_id: null},
    bone: {label: '뼈', color: '#64748B', text: '#1E293B', body_id: 4},
    muscle: {label: '근육', color: '#EF4444', text: '#7F1D1D', body_id: null},
    heart: {label: '심장', color: '#DC2626', text: '#7F1D1D', body_id: null},
    intestine: {label: '장', color: '#7C3AED', text: '#4C1D95', body_id: null},
    liver: {label: '간', color: '#10B981', text: '#065F46', body_id: 2},
    stomach: {label: '위', color: '#F59E0B', text: '#78350F', body_id: null},
    lung: {label: '폐', color: '#3B82F6', text: '#1E3A8A', body_id: 3},
};

let selected = new Set();   // 선택된 part key들
let likedIds = new Set();   // 좋아요한 supplementId들
let suppCache = {};         // { partKey: [BodyDTO, ...] } 캐시
let sort = 'recent';
let page = 1;
let modalId = null;
let allMode = false;

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

    return fetch(`body?action=supps&bodyId=${bodyId}&sort=recent`)
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
// ✅ 수정: alert 대신 로그인 모달 표시
function toggleLike(id) {
    if (!isLogin) {
        showLoginModal(); // 로그인 모달 띄우기
        return;
    }
    fetch(`body?action=like&suppId=${id}`, {method: 'POST'})
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

// ✅ 추가: 로그인 유도 모달 함수
function showLoginModal() {
    // 1. 기존에 이미 떠 있는 모달이 있으면 제거
    const existing = document.getElementById('login-modal-overlay');
    if (existing) existing.remove();

    // 2. 오버레이 생성 (화면 전체를 덮도록 fixed 설정)
    const overlay = document.createElement('div');
    overlay.id = 'login-modal-overlay';
    overlay.style.cssText = `
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10000; /* 모달보다 높게 설정 */
        padding: 16px;
    `;
    overlay.onclick = (e) => {
        if (e.target === overlay) closeLoginModal();
    };

    // 3. 모달 컨텐츠
    overlay.innerHTML = `
      <div style="background:#fff; border-radius:12px; padding:28px 24px;
                  width:min(340px,90%); text-align:center;
                  box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                  border:1px solid #e0e0e0;"
           onclick="event.stopPropagation()">
        <div style="font-size:22px; margin-bottom:8px">🔒</div>
        <p style="font-size:15px; font-weight:600; margin-bottom:6px; color:#333;">
          로그인이 필요합니다
        </p>
        <p style="font-size:13px; color:#666; margin-bottom:20px;">
          좋아요 기능은 로그인 후 이용 가능합니다.
        </p>
        <div style="display:flex; gap:8px; justify-content:center;">
          <button onclick="location.href='user-Login'"
            style="padding:9px 20px; background:#3B82F6; color:#fff;
                   border:none; border-radius:8px; cursor:pointer; font-size:13px; font-weight:600;">
            로그인하기
          </button>
          <button onclick="closeLoginModal()"
            style="padding:9px 16px; background:#fff;
                   border:1px solid #ccc; border-radius:8px;
                   cursor:pointer; font-size:13px; color:#666;">
            닫기
          </button>
        </div>
      </div>`;

    // 4. 특정 영역이 아닌 body에 직접 붙여서 화면 중앙에 띄움
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

    // 1. 모든 PARTS의 키를 selected Set에 추가 (이게 핵심!)
    selected.clear();
    Object.keys(PARTS).forEach(k => selected.add(k));

    // 2. 체크박스 및 SVG UI 갱신
    syncCheckboxUI();

    // bodyId 있는 모든 부위 fetch
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
    renderList();
}

function setSort(s, btn) {
    sort = s;
    page = 1;
    document.querySelectorAll('.sort-btn').forEach(b => b.classList.remove('on'));
    btn.classList.add('on');
    renderList();
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
    if (sort === 'like') return arr.sort((a, b) => (b.likes + (likedIds.has(b.id) ? 1 : 0)) - (a.likes + (likedIds.has(a.id) ? 1 : 0)));
    return arr.sort((a, b) => b.id - a.id);
}

// ── 리스트 렌더링 ──
function renderList() {
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
        <span class="card-stats">&#128065; ${s.views} · &#9829; ${s.likes + (likedIds.has(s.id) ? 1 : 0)}</span>
        <button class="like-btn ${likedIds.has(s.id) ? 'on' : ''}"
          onclick="event.stopPropagation();toggleLike(${s.id})">
          ${likedIds.has(s.id) ? '&#9829; 취소' : '&#9825; 좋아요'}
        </button>
      </div>
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
    fetch(`body?action=detail&suppId=${id}`)
        .then(r => r.json())
        .then(data => {
            for (const p in suppCache) {
                const s = suppCache[p].find(x => x.id === id);
                if (s) s.views = data.supplementViewCount;
            }
            refreshModal(id);
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

    // 기존에 떠 있는 모달이 있다면 중복 방지를 위해 제거
    const existing = document.getElementById('supp-modal-overlay');
    if (existing) existing.remove();

    // 1. 오버레이(배경) 생성
    const overlay = document.createElement('div');
    overlay.id = 'supp-modal-overlay';
    overlay.style.cssText = `
        position: fixed;
        inset: 0;
        background: rgba(0,0,0,0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        padding: 16px;
    `;

    // 배경 클릭 시 닫기
    overlay.onclick = (e) => {
        if (e.target === overlay) closeModal();
    };

    // 2. 모달 컨텐츠 작성 (이미지 경로 처리 추가)
    const imgHtml = s.imgPath
        ? `<img src="${s.imgPath}" style="width:52px; height:52px; border-radius:10px; object-fit:cover;" onerror="this.onerror=null; this.src='images/default.png';">` // ✅ 수정: onerror 로직 보강
        : `<div style="width:52px; height:52px; border-radius:10px; background:${pt.color}22; display:flex; align-items:center; justify-content:center; font-size:22px;">💊</div>`;

    overlay.innerHTML = `
      <div style="background:#fff; border-radius:14px; padding:24px;
                  width:min(420px,95%); max-height:85vh; overflow-y:auto;
                  border:1px solid #e0e0e0; box-shadow: 0 10px 25px rgba(0,0,0,0.1);">
        <div style="display:flex; align-items:center; gap:12px; margin-bottom:14px;">
          ${imgHtml}
          <div>
            <div style="font-size:17px; font-weight:600; color:#333;">${s.name}</div>
            <span style="font-size:10px; padding:2px 8px; border-radius:20px;
                         background:${pt.color}22; color:${pt.text};
                         border:1px solid ${pt.color}55; display:inline-block; margin-top:3px;">
              ${pt.label}
            </span>
          </div>
        </div>
        <div style="display:flex; gap:8px; margin-bottom:7px;">
          <span style="font-size:12px; color:#666; min-width:60px; line-height:1.6;">효능</span>
          <span style="font-size:13px; line-height:1.6; color:#444;">${s.efficacy}</span>
        </div>
        <div style="display:flex; gap:8px; margin-bottom:7px;">
          <span style="font-size:12px; color:#666; min-width:60px; line-height:1.6;">복용법</span>
          <span style="font-size:13px; line-height:1.6; color:#444;">${s.dosage || '-'}</span>
        </div>
        <div style="display:flex; gap:8px; margin-bottom:7px;">
          <span style="font-size:12px; color:#666; min-width:60px; line-height:1.6;">복용 시기</span>
          <span style="font-size:13px; line-height:1.6; color:#444;">${s.timing || '-'}</span>
        </div>
        <div style="font-size:11px; color:#A32D2D; background:#FCEBEB;
                    border-radius:8px; padding:8px 10px; margin-top:4px;">
          ⚠ ${s.caution || '해당 없음'}
        </div>
        <div style="display:flex; justify-content:space-between; align-items:center;
                    margin-top:16px; padding-top:12px; border-top:1px solid #f0f0f0;">
          <span style="font-size:12px; color:#999;">
            👁 ${s.views} &nbsp; ♥ ${s.likes + (on ? 1 : 0)}
          </span>
          <div style="display:flex; gap:8px;">
            <button onclick="toggleLike(${id})"
              style="font-size:12px; padding:5px 14px; border-radius:8px; cursor:pointer;
                     border:1px solid ${on ? '#D4537E' : '#ccc'};
                     background:${on ? '#FFF0F5' : 'transparent'};
                     color:${on ? '#9B2257' : '#666'}; transition: all 0.2s;">
              ${on ? '♥ 취소' : '♡ 좋아요'}
            </button>
            <button onclick="closeModal()"
              style="font-size:12px; padding:5px 14px; border:1px solid #ccc;
                     border-radius:8px; background:transparent; cursor:pointer; color:#666;">
              닫기
            </button>
          </div>
        </div>
      </div>`;

    // body에 직접 붙임 (z-index 9999로 최상단 보장)
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
document.querySelectorAll('.body-part').forEach(el => {
    el.addEventListener('click', () => {
        const p = el.dataset.part;
        if (p) {
            allMode = false;
            togglePart(p);
        }
    });
});

buildCheckboxes();