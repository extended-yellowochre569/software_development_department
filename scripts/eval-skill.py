#!/usr/bin/env python3
"""
eval-skill.py — LLM-as-Judge skill evaluator (SDD)
Uses Gemini 2.0 Flash to score SKILL.md quality.

Usage:
  python3 scripts/eval-skill.py brainstorm
  python3 scripts/eval-skill.py code-review sprint-plan
  python3 scripts/eval-skill.py --all

Requires: GEMINI_API_KEY env var
"""

import os
import re
import sys
import json
import argparse
from pathlib import Path

try:
    import google.genai as genai
    from google.genai import types
except ImportError:
    print("ERROR: google-genai not installed. Run: pip install google-genai")
    sys.exit(1)

# Fix Windows console encoding
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# ─── Config ──────────────────────────────────────────────────────────────────

SKILLS_DIR = Path(__file__).parent.parent / ".claude" / "skills"
MODEL      = "gemini-2.5-flash"
PASS_THRESHOLD = 3.5   # avg score để PASS

DIMENSIONS = {
    "clarity":       "Workflow rõ ràng — agent đọc SKILL.md có hiểu ngay cần làm gì không?",
    "completeness":  "Đầy đủ nội dung — các bước, output format, edge cases có được cover không?",
    "actionability": "Có thể thực thi — agent có thể follow mà không cần đoán mò hay suy luận thêm không?",
    "structure":     "Cấu trúc tốt — frontmatter đầy đủ, sections rõ ràng, không mơ hồ không?",
}

JUDGE_PROMPT = """\
Bạn là một AI agent quality evaluator. Nhiệm vụ của bạn là đánh giá chất lượng \
của một SKILL.md — tài liệu hướng dẫn cho AI agent thực thi một workflow.

Hãy chấm điểm SKILL.md sau đây theo 4 chiều, mỗi chiều từ 1-5:

1. clarity       (1-5): {clarity}
2. completeness  (1-5): {completeness}
3. actionability (1-5): {actionability}
4. structure     (1-5): {structure}

Thang điểm:
  5 = Xuất sắc, không cần cải thiện
  4 = Tốt, có vài điểm nhỏ có thể cải thiện
  3 = Đạt yêu cầu nhưng có khoảng trống đáng kể
  2 = Yếu, thiếu nhiều thứ quan trọng
  1 = Không dùng được

Trả về JSON hợp lệ ĐÚNG format sau (không có markdown, không có text thừa):
{{
  "clarity": <số 1-5>,
  "completeness": <số 1-5>,
  "actionability": <số 1-5>,
  "structure": <số 1-5>,
  "reasoning": {{
    "clarity": "<1 câu giải thích>",
    "completeness": "<1 câu giải thích>",
    "actionability": "<1 câu giải thích>",
    "structure": "<1 câu giải thích>"
  }},
  "top_issue": "<vấn đề lớn nhất cần cải thiện, hoặc 'none' nếu không có>"
}}

--- SKILL.MD BẮT ĐẦU ---
{skill_content}
--- SKILL.MD KẾT THÚC ---
"""

# ─── Helpers ─────────────────────────────────────────────────────────────────

def load_skill(skill_name: str) -> tuple[str, str]:
    """Load SKILL.md content. Returns (skill_type, content)."""
    skill_file = SKILLS_DIR / skill_name / "SKILL.md"
    if not skill_file.exists():
        raise FileNotFoundError(f"Skill '{skill_name}' not found at {skill_file}")
    content = skill_file.read_text(encoding="utf-8", errors="replace")
    # Extract type from frontmatter
    fm_match = re.search(r'^type:\s*(\S+)', content, re.M)
    skill_type = fm_match.group(1).strip('"') if fm_match else "workflow"
    return skill_type, content


def call_judge(client, skill_name: str, content: str) -> dict:
    """Call Gemini as LLM judge. Returns parsed scores."""
    prompt = JUDGE_PROMPT.format(
        clarity=DIMENSIONS["clarity"],
        completeness=DIMENSIONS["completeness"],
        actionability=DIMENSIONS["actionability"],
        structure=DIMENSIONS["structure"],
        skill_content=content[:32000],  # Gemini 2.5 Flash hỗ trợ 1M token
    )
    response = client.models.generate_content(
        model=MODEL,
        contents=prompt,
        config=types.GenerateContentConfig(
            temperature=0.1,
            response_mime_type="application/json",
        ),
    )
    raw = response.text.strip()
    # Strip markdown code fences nếu có
    raw = re.sub(r'^```(?:json)?\s*', '', raw)
    raw = re.sub(r'\s*```$', '', raw)
    return json.loads(raw)


def format_bar(score: int, max_score: int = 5) -> str:
    filled = "█" * score
    empty  = "░" * (max_score - score)
    return filled + empty


def print_result(skill_name: str, skill_type: str, scores: dict):
    dims = ["clarity", "completeness", "actionability", "structure"]
    avg  = sum(scores[d] for d in dims) / len(dims)
    passed = avg >= PASS_THRESHOLD

    status = "\033[92mPASS\033[0m" if passed else "\033[91mFAIL\033[0m"
    tag    = f"[{skill_type}]"

    print(f"\n{'═'*52}")
    print(f"  Skill  : {skill_name} {tag}")
    print(f"  Model  : {MODEL}")
    print(f"{'─'*52}")

    for dim in dims:
        score     = scores[dim]
        bar       = format_bar(score)
        reasoning = scores.get("reasoning", {}).get(dim, "")
        color     = "\033[92m" if score >= 4 else ("\033[93m" if score == 3 else "\033[91m")
        print(f"  {dim:<14} {color}{bar}\033[0m  {score}/5")
        if reasoning:
            print(f"               \033[90m{reasoning}\033[0m")

    print(f"{'─'*52}")
    print(f"  Average: {avg:.1f}/5   {status}")

    top_issue = scores.get("top_issue", "none")
    if top_issue and top_issue.lower() != "none":
        print(f"  Issue  : \033[93m{top_issue}\033[0m")

    print(f"{'═'*52}\n")
    return passed


# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="SDD Skill Evaluator (Gemini Judge)")
    parser.add_argument("skills", nargs="*", help="Skill names to evaluate")
    parser.add_argument("--all", action="store_true", help="Evaluate all skills")
    args = parser.parse_args()

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("ERROR: GEMINI_API_KEY environment variable not set.")
        sys.exit(1)

    client = genai.Client(api_key=api_key)

    # Build skill list
    if args.all:
        skill_names = sorted([
            d.name for d in SKILLS_DIR.iterdir()
            if d.is_dir() and d.name != "templates" and (d / "SKILL.md").exists()
        ])
    elif args.skills:
        skill_names = args.skills
    else:
        parser.print_help()
        sys.exit(1)

    total = passed_count = 0

    for skill_name in skill_names:
        total += 1
        try:
            skill_type, content = load_skill(skill_name)
            print(f"Evaluating '{skill_name}'...", end=" ", flush=True)
            scores = call_judge(client, skill_name, content)
            print("done")
            ok = print_result(skill_name, skill_type, scores)
            if ok:
                passed_count += 1
        except FileNotFoundError as e:
            print(f"\nERROR: {e}")
        except json.JSONDecodeError as e:
            print(f"\nERROR: Judge returned invalid JSON for '{skill_name}': {e}")
        except Exception as e:
            print(f"\nERROR evaluating '{skill_name}': {e}")

    if total > 1:
        print(f"Summary: {passed_count}/{total} skills passed (threshold: {PASS_THRESHOLD}/5)\n")


if __name__ == "__main__":
    main()
