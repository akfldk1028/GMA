"""
Auto-Claude Agent Invoker (GMA)
================================

Claude Skills에서 Auto-Claude의 커스텀 에이전트를 호출하는 스크립트.

Usage:
    python invoke_autoclaude.py --agent gma_pdf_viewer --task "PDF 북마크 구현"
    python invoke_autoclaude.py --list  # 사용 가능한 에이전트 목록
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path

# Auto-Claude 경로
AUTO_CLAUDE_BACKEND = Path("C:/DK/GMA/clone/AC247/Auto-Claude/apps/backend")
PYTHON_PATH = AUTO_CLAUDE_BACKEND / ".venv/Scripts/python.exe"

# GMA 프로젝트 에이전트 (필요시 custom_agents/config.json에 추가)
GMA_AGENTS = {
    "gma_pdf_viewer": "PDF 뷰어 (pdfrx, 마커, 텍스트 선택)",
    "gma_note_editor": "Markdown 에디터 (Wiki-link, LaTeX, Frontmatter)",
    "gma_workspace": "워크스페이스 (3패널 레이아웃, 분할 뷰)",
    "gma_file_manager": "파일 매니저 (트리 뷰, 검색, Hive 저장)",
    "gma_data_model": "데이터 모델 (Freezed, PDF-노트 연동)",
}


def list_agents():
    """사용 가능한 에이전트 목록 출력"""
    print("\n=== GMA Custom Agents ===\n")
    for agent, desc in GMA_AGENTS.items():
        print(f"  {agent:25} - {desc}")
    print()


def invoke_agent(agent_type: str, task: str) -> tuple[str, str]:
    """
    Auto-Claude 에이전트 호출

    Args:
        agent_type: 에이전트 타입 (예: gma_pdf_viewer)
        task: 실행할 작업 설명

    Returns:
        (stdout, stderr) 튜플
    """
    if agent_type not in GMA_AGENTS:
        print(f"Error: Unknown agent '{agent_type}'")
        print("Use --list to see available agents")
        sys.exit(1)

    print(f"\n=== Invoking Agent: {agent_type} ===")
    print(f"Task: {task}\n")

    guide = f"""
To use this agent with Auto-Claude:

1. Create a spec:
   cd {AUTO_CLAUDE_BACKEND}
   {PYTHON_PATH} spec_runner.py --task "{task}"

2. Or use the custom agent prompt directly:
   The agent prompt is at:
   {AUTO_CLAUDE_BACKEND / 'custom_agents/prompts' / f'{agent_type}.md'}

3. Agent capabilities:
   - {GMA_AGENTS[agent_type]}
"""
    print(guide)
    return "", ""


def main():
    parser = argparse.ArgumentParser(
        description="Invoke Auto-Claude agents from Claude Skills (GMA)"
    )
    parser.add_argument(
        "--agent", "-a",
        help="Agent type to invoke (e.g., gma_pdf_viewer)"
    )
    parser.add_argument(
        "--task", "-t",
        help="Task description"
    )
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List available agents"
    )

    args = parser.parse_args()

    if args.list:
        list_agents()
        return

    if not args.agent or not args.task:
        parser.print_help()
        print("\nExamples:")
        print("  python invoke_autoclaude.py --agent gma_pdf_viewer --task 'PDF 북마크 구현'")
        print("  python invoke_autoclaude.py --list")
        return

    invoke_agent(args.agent, args.task)


if __name__ == "__main__":
    main()
