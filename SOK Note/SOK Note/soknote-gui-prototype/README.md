# SOK Note — GUI Prototype

Flutter 개발자 핸드오프용 HTML/CSS 프로토타입입니다.

## 시작하기

`index.html`을 브라우저에서 바로 열면 됩니다. 별도 서버 불필요.

## 폴더 구조

```
soknote-gui-prototype/
├── index.html          # 진입점 — 전체 프로토타입
├── css/
│   ├── reset.css       # 브라우저 기본 스타일 초기화
│   ├── tokens.css      # 디자인 토큰 (CSS 변수)
│   ├── layout.css      # 앱 프레임, 그리드/플렉스 레이아웃
│   └── components.css  # 재사용 컴포넌트 스타일
├── js/
│   └── main.js         # 화면 상태 전환 (사이드바/검색/메뉴)
├── assets/
│   ├── images/         # 스크린샷, 참고 이미지
│   └── icons/          # 아이콘 파일 (svg 등)
├── screens/
│   └── home.html       # 홈 화면 컴포넌트 조합 참고
└── components/         # 컴포넌트별 HTML 조각
    ├── appbar.html
    ├── sidebar.html
    ├── note-card.html
    ├── sort-bar.html
    ├── search-bar.html
    └── overflow-menu.html
```

## 상태 전환 (Dev Panel)

화면 하단 Dev Panel 버튼으로 4가지 상태를 전환합니다.

| 버튼 | 상태 |
|------|------|
| Default | 홈 기본 상태 |
| Sidebar | 사이드바 펼침 |
| Search | 검색바 활성화 |
| Menu | 오버플로우 메뉴 오픈 |

## 디자인 토큰 수정

`css/tokens.css`의 `:root` 변수만 바꾸면 전체 색상·간격이 일괄 적용됩니다.

```css
--color-accent: #F4A426;   /* 포인트 컬러 */
--radius-card:  12px;       /* 카드 모서리 */
--spacing-md:   16px;       /* 기본 간격 */
```

## 컴포넌트 교체 방법

1. `components/` 안의 해당 `.html` 파일을 수정
2. `index.html`의 같은 마크업 블록을 붙여넣기
3. `css/components.css`에서 해당 컴포넌트 섹션 스타일 수정

## CSS 클래스 규칙 (BEM 기반)

- 블록: `appbar`, `note-card`, `sort-bar`, `search-bar`, `overflow-menu`
- 요소: `appbar__title`, `note-card__body`
- 상태: `app-sidebar--expanded`, `search-bar--active`, `overflow-menu--open`
