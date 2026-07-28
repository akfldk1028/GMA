// main.js — 화면 상태 전환 (Note 편집 화면)
// 홈 화면 JS와 충돌하지 않도록 모든 탐색/상태를 .note-shell 내부로 스코프 제한한다.

(function initNoteEditor() {
  const noteRoot = document.querySelector('.note-shell');
  if (!noteRoot) return; // 이 화면이 아니면 아무것도 하지 않음

  // 상태는 이 IIFE 내부에서만 관리 (전역 const 아님)
  const State = {
    moreMenuOpen:  false,
    aiAgentOpen:   false,
    activeRailTab: 0,
  };

  // .note-shell 기준으로만 요소 탐색
  const moreMenu      = noteRoot.querySelector('.overflow-menu');
  const aiAgent       = noteRoot.querySelector('.ai-agent');
  const railTabs      = noteRoot.querySelectorAll('.note-rail__tab');
  const colorSwatches = noteRoot.querySelectorAll('.color-swatch');
  const sizeDots      = noteRoot.querySelectorAll('.size-dot');

  function applyState() {
    moreMenu?.classList.toggle('overflow-menu--open', State.moreMenuOpen);
    // AI Agent는 우측 노트 영역 위에 뜨는 플로팅 패널 — Scraps 뷰는 뒤에 그대로 유지
    aiAgent?.classList.toggle('ai-agent--active', State.aiAgentOpen);
  }

  function toggleMoreMenu() { State.moreMenuOpen = !State.moreMenuOpen; applyState(); }
  function openAiAgent()    { State.aiAgentOpen = true;  State.moreMenuOpen = false; applyState(); }
  function closeAiAgent()   { State.aiAgentOpen = false; applyState(); }

  noteRoot.querySelector('[data-action="more"]')
    ?.addEventListener('click', e => {
      e.stopPropagation();
      toggleMoreMenu();
    });

  noteRoot.querySelector('[data-action="ai-agent"]')
    ?.addEventListener('click', openAiAgent);

  noteRoot.querySelector('[data-action="close-ai-agent"]')
    ?.addEventListener('click', closeAiAgent);

  // 바깥 클릭 시 더보기 메뉴 닫기 (document 레벨이지만 상태는 이 화면 것만 조작)
  document.addEventListener('click', () => {
    if (State.moreMenuOpen) { State.moreMenuOpen = false; applyState(); }
  });
  moreMenu?.addEventListener('click', e => e.stopPropagation());

  // 좌측 레일 탭 선택
  railTabs.forEach((tab, index) => {
    tab.addEventListener('click', () => {
      railTabs.forEach(t => t.classList.remove('note-rail__tab--active'));
      tab.classList.add('note-rail__tab--active');
      State.activeRailTab = index;
    });
  });

  // 펜 색상 선택
  colorSwatches.forEach(swatch => {
    swatch.addEventListener('click', () => {
      colorSwatches.forEach(s => s.classList.remove('color-swatch--active'));
      swatch.classList.add('color-swatch--active');
    });
  });

  // 펜 굵기 선택
  sizeDots.forEach(dot => {
    dot.addEventListener('click', () => {
      sizeDots.forEach(d => d.classList.remove('size-dot--active'));
      dot.classList.add('size-dot--active');
    });
  });

  // 디바이스 프레임 스케일 (1280×800 → 브라우저 창에 맞춤)
  function scaleFrame() {
    const frame = document.querySelector('.device-frame');
    if (!frame) return;
    const scale = Math.min(window.innerWidth / 1280, window.innerHeight / 800, 1);
    frame.style.transform = `translate(-50%, -50%) scale(${scale})`;
  }
  scaleFrame();
  window.addEventListener('resize', scaleFrame);

  applyState();
})();
