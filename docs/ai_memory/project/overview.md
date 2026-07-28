---
name: project_overview
description: LinkNote 앱 프로젝트 개요 - Flutter PDF 메모 앱, 기술 스택, 완료 기능 목록
type: project
---

# LinkNote 프로젝트 개요

- **앱 이름**: LinkNote (패키지: `com.clickaround.linknote`)
- PDF 좌표 연동 Markdown 메모 앱 (Flutter)
- 3패널: 사이드바 + PDF 뷰어(pdfrx) + Markdown 에디터
- 상태관리: Riverpod, 모델: Freezed, UI: ShadCN, 라우팅: GoRouter
- 참조 코드: `clone/pdfrx`, `clone/printnotes`

## 완료된 기능 (Task 순서)
- 기본 인프라: 모델, 스토리지(Hive), 라우팅, 테마
- PDF 뷰어: 렌더링, 줌, 텍스트 선택, 영역 캡처, 드로잉
- 마커 시스템: 5색, PDF↔노트 양방향 점프
- Markdown 에디터: Wiki-link, LaTeX, Frontmatter, 자동저장
- OCR 스캐폴딩: OcrBackend 인터페이스, Ollama LLaVA 연동 준비
- GMA-MD 블록: concept, theorem, proof, example, summary, timeline, mindmap, flow
- **ScrapNote 시스템** (Task 022~037)
- **Knowledge Graph**: force-directed 노드 그래프
- **Dashboard**: 3섹션 (Recent Docs + Note Tree + Recent Scraps)
- **Home UI 리워크**

## 빌드/배포 상태 (2026-03-06)
- 컴파일: 에러 0
- **Play Store 배포 준비 완료**
  - 서명키: `android/app/upload-keystore.jks`
  - 현재 버전: `1.0.4+6`
