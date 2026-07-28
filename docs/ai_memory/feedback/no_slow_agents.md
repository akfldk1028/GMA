---
name: no_slow_agents
description: 시간 오래 걸리는 Agent 서브프로세스 사용 금지, 직접 도구 사용 선호
type: feedback
---

# Agent 서브프로세스 느림 금지

웹 검색 등 간단한 작업에 Agent 서브프로세스를 쓰지 말 것.
WebSearch, Grep 등 직접 도구를 사용해서 빠르게 처리.

**Why:** 유저가 "하루종일찾니"라고 피드백 — Agent 호출이 너무 느리고 답답함
**How to apply:** 검색/조사 작업은 WebSearch, mcp__brave-search 등 직접 도구 호출. Agent는 코드 수정이 복잡할 때만 사용.
