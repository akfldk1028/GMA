---
name: gma-build
description: |
  GMA Flutter 프로젝트 빌드 자동화. 의존성 설치, 코드 생성(Freezed/Riverpod), 앱 빌드.
  사용 시점: (1) 코드 변경 후 빌드, (2) Freezed 모델 수정 후, (3) 새 의존성 추가 후
  사용 금지: 앱 실행만 할 때(flutter run), 코드 분석(flutter analyze)
argument-hint: "[all|flutter|web|apk|code]"
allowed-tools: Read, Grep, Glob, Bash
---

# GMA Build Skill

Flutter 앱 빌드를 실행합니다.

## When to Use
- 코드 변경 후 빌드할 때
- Freezed/Riverpod 파일 수정 후 코드 생성 필요 시
- 새 패키지 추가 후 의존성 설치 시
- CI에서 빌드 검증 시

## When NOT to Use
- 단순 코드 확인 → `flutter analyze` 직접 사용
- 앱 실행만 → `flutter run` 직접 사용

## Quick Start
```bash
/gma-build code    # 코드 생성만
/gma-build web     # Web 빌드
```

## Usage

```
/gma-build [target]
```

### 타겟 옵션
- `all` - 전체 빌드 (기본값)
- `flutter` - Flutter 앱만 빌드
- `web` - Flutter Web 빌드
- `apk` - Android APK 빌드
- `code` - 코드 생성만 (Freezed, Riverpod)

## 빌드 프로세스

### Step 1: Flutter 의존성 설치
```bash
cd C:\DK\GMA\frontend
flutter pub get
```

### Step 2: 코드 생성 (Freezed, Riverpod)
```bash
cd C:\DK\GMA\frontend
dart run build_runner build --delete-conflicting-outputs
```

### Step 3: 빌드 실행
```bash
# Web 빌드
flutter build web

# APK 빌드
flutter build apk
```

## 프로젝트 경로

- **Flutter 앱**: `C:\DK\GMA\frontend`
- **Auto-Claude**: `C:\DK\GMA\clone\AC247\Auto-Claude`
- **참조 코드**: `C:\DK\GMA\clone\pdfrx`, `C:\DK\GMA\clone\printnotes`

## 에러 처리

### 일반적인 에러와 해결책

1. **pub get 실패**
   - 인터넷 연결 확인
   - pubspec.yaml 문법 확인

2. **build_runner 에러**
   - `.dart_tool/` 폴더 삭제 후 재시도
   - `flutter clean` 실행

3. **빌드 실패**
   - 에러 로그 확인
   - 필요시 Auto-Claude의 qa_fixer 에이전트 활용

## Auto-Claude 연동

복잡한 빌드 에러는 Auto-Claude를 활용할 수 있습니다:

```bash
cd C:\DK\GMA\clone\AC247\Auto-Claude\apps\backend
.venv\Scripts\python.exe run.py --task "빌드 에러 수정: [에러 내용]"
```

## 빌드 결과

- **Web**: `frontend/build/web/`
- **APK**: `frontend/build/app/outputs/flutter-apk/`

## 다음 단계

빌드 완료 후:
- `/gma-test` - 테스트 실행
