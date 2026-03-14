# 04. MarkerPillsStrip — 좌측 마커 스트립

## 파일 위치
```
lib/features/pdf_viewer/pages/widgets/marker_pills_strip.dart
```

## 역할
화면 좌측 72px 너비의 세로 스트립. 생성된 마커를 색상 dot + 페이지 번호 + 텍스트 미리보기로 표시.

## 레이아웃
```
┌────┐
│ 🔴 │ P3
│ 텍스트│
├────┤
│ 🟡 │ P5
│ 텍스트│
├────┤
│ 🟢 │ P7
│ ...│
└────┘
  72px
```

## 인터랙션
| 제스처 | 콜백 | 동작 |
|--------|------|------|
| 탭 | `onMarkerTap(marker)` | PDF 해당 페이지/위치로 점프 |
| 롱프레스 | `onMarkerLongPress(marker)` | 에디터 모달 열기 |

## 의존성
- `currentMarkersProvider` — 마커 리스트 watch
- 빈 상태: 세로로 "MARKERS" 텍스트 표시

## 수정 시 주의사항
- MarkerColor.pen 제외하고 표시 (드로잉 마커는 다른 UI)
- Container width: 72px 고정, Row의 첫 번째 자식
