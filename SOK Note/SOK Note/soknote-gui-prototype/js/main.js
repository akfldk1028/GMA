// main.js — 화면 상태 전환

const State = {
  sidebarExpanded:  false,
  searchActive:     false,
  overflowMenuOpen: false,
  sortDropdownOpen: false,
};

const sidebar      = document.querySelector('.app-sidebar');
const appbar       = document.querySelector('.appbar');
const searchAppbar = document.querySelector('.search-appbar');
const overflowMenu = document.querySelector('.overflow-menu');
const sortDropdown = document.querySelector('.sort-dropdown');

function applyState() {
  sidebar?.classList.toggle('app-sidebar--expanded', State.sidebarExpanded);
  appbar?.classList.toggle('appbar--hidden', State.searchActive);
  searchAppbar?.classList.toggle('search-appbar--active', State.searchActive);
  overflowMenu?.classList.toggle('overflow-menu--open', State.overflowMenuOpen);
  sortDropdown?.classList.toggle('sort-dropdown--open', State.sortDropdownOpen);
}

function toggleSortDropdown() {
  State.sortDropdownOpen = !State.sortDropdownOpen;
  State.overflowMenuOpen = false;
  applyState();
}

function toggleSidebar() {
  State.sidebarExpanded = !State.sidebarExpanded;
  applyState();
}

function openSearch() {
  State.searchActive     = true;
  State.overflowMenuOpen = false;
  applyState();
  setTimeout(() => document.querySelector('.search-appbar__input')?.focus(), 50);
}

function closeSearch() {
  State.searchActive = false;
  applyState();
}

function toggleOverflow() {
  State.overflowMenuOpen = !State.overflowMenuOpen;
  State.sortDropdownOpen = false;
  applyState();
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelector('.sidebar-toggle-btn')
    ?.addEventListener('click', toggleSidebar);

  document.querySelector('[data-action="search"]')
    ?.addEventListener('click', openSearch);

  document.querySelector('.search-appbar__back-btn')
    ?.addEventListener('click', closeSearch);

  document.querySelector('[data-action="more"]')
    ?.addEventListener('click', e => {
      e.stopPropagation();
      toggleOverflow();
    });

  document.querySelector('[data-action="sort"]')
    ?.addEventListener('click', e => {
      e.stopPropagation();
      toggleSortDropdown();
    });

  // 정렬 항목 선택
  sortDropdown?.querySelectorAll('.sort-dropdown__item').forEach(item => {
    item.addEventListener('click', () => {
      sortDropdown.querySelectorAll('.sort-dropdown__item').forEach(i => i.classList.remove('sort-dropdown__item--active'));
      item.classList.add('sort-dropdown__item--active');
      document.querySelector('.sort-bar__label').textContent = item.textContent;
      State.sortDropdownOpen = false;
      applyState();
    });
  });

  document.addEventListener('click', () => {
    if (State.overflowMenuOpen) { State.overflowMenuOpen = false; applyState(); }
    if (State.sortDropdownOpen) { State.sortDropdownOpen = false; applyState(); }
  });
  overflowMenu?.addEventListener('click', e => e.stopPropagation());
  sortDropdown?.addEventListener('click', e => e.stopPropagation());

  // 디바이스 프레임 스케일
  function scaleFrame() {
    const frame = document.querySelector('.device-frame');
    if (!frame) return;
    const scale = Math.min(window.innerWidth / 1280, window.innerHeight / 800, 1);
    frame.style.transform = `translate(-50%, -50%) scale(${scale})`;
  }
  scaleFrame();
  window.addEventListener('resize', scaleFrame);

  applyState();
});
