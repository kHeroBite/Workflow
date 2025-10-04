# AGENTS.md

이 문서는 Codex CLI가 이 프로젝트를 다룰 때의 특화된 지침을 제공합니다.

## Codex CLI 전용 설정

### 버전 관리 (Codex 전용)
- 모든 커밋 메시지는 한국어로 작성합니다. **커밋 메시지 앞에 `[커서]` 태그를 붙입니다.**
- 코드 변경 시 `.commit_message.txt`에 한 줄 요약(한국어) + 적절한 이모지를 기록합니다.
- `git revert` 관련 작업이면 `.commit_message.txt`는 비워둡니다.
- 기존 내용은 덮어쓰기, 의존성과 참조는 꼼꼼히 확인합니다.

### 한글 인코딩 정책 (Codex 특화)
**Codex는 한글 처리에 취약하므로 다음 규칙을 반드시 준수하세요:**

- 에이전트 커뮤니케이션(진행 멘트, 계획, 결과 요약, 제안, 질문)은 항상 한국어로 작성합니다.
- 도구 실행 전 안내, 계획, 최종 결과 메시지 모두 한국어로 제공합니다.
- 코드 변경 시 주석·요약도 한국어를 기본으로 하며, 필요 시 영문 병기합니다.
- 모든 텍스트 파일은 UTF-8(무 BOM)을 기본으로 사용합니다. 콘솔 출력은 UTF-8로 설정합니다.
  - PowerShell: `chcp 65001`, `[Console]::InputEncoding = [Text.UTF8]`, `[Console]::OutputEncoding = [Text.UTF8]`, `$OutputEncoding = [Text.UTF8]`
  - Git: `i18n.commitEncoding = utf-8`, `i18n.logOutputEncoding = utf-8`
- **중요**: PowerShell CLI에서 `Set-Content`, `Add-Content`, `Out-File`, 리다이렉션(`>`, `>>`)을 기본 옵션으로 실행하면 ANSI/UTF-16으로 저장되어 UTF-8 한글이 깨집니다. 항상 `-Encoding UTF8`을 지정하세요.
- Python 스크립트에서도 `encoding='utf-8'`을 사용합니다.
- 대량 치환/스크립트 실행 후에는 즉시 git diff로 한글이 깨지지 않았는지 검수합니다.

### 작업 완료 알림 (Codex 전용)
**🚨 절대 필수 🚨: 모든 작업 완료 후, 작업이 종료되기 직전에 반드시 ntfy 알림을 보내야 합니다!**

**⚠️ 중요: 어떤 이유로든 ntfy 알림을 보내지 않으면 안됩니다. 작업 완료 직전에 반드시 실행하세요!**

모든 작업 완료 후, 작업 요약과 함께 최종 완료 알림을 보내야 합니다:
1. JSON 파일 생성:
```bash
echo '{
  "topic": "MarsAlert",
  "title": "[코덱스] 작업 완료",
  "message": "작업 요약: [실제 수행한 작업들의 구체적인 설명과 개선 효과]\n\n커밋 내역:\n- [커밋 메시지1]\n- [커밋 메시지2]",
  "priority": 4,
  "tags": ["checkmark", "AI", "chatGPT", "deep think", "complete"]
}' > temp_codex_final.json
```
2. 알림 전송:
```bash
curl https://ntfy.sh \
  -H "Content-Type: application/json; charset=utf-8" \
  --data-binary @temp_codex_final.json
```
3. 임시 파일 정리:
```bash
rm temp_codex_final.json
```

## 🚨🚨🚨 최종 강조사항 🚨🚨🚨

**절대 잊지 마세요: 모든 대화와 작업이 끝나기 직전에 반드시 ntfy 알림을 보내야 합니다!**

**이는 선택사항이 아닙니다. 필수 요구사항입니다!**

작업 완료 → ntfy 알림 전송 → 대화 종료

