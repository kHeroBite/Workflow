# AGENTS.md

이 문서는 Codex CLI가 Workflow 프로젝트에서 작업할 때 필요한 모든 정보를 포함합니다.

**📋 이 파일은 프로젝트 운영 절차와 Codex CLI 전용 설정을 함께 제공합니다.**

## Codex CLI 전용 설정

### 버전 관리 (Codex 전용)
* **⚠️ 주요 변경 포인트마다 git 커밋**을 반드시 수행합니다.
* 코드 변경 시 반드시 `.commit_message.txt`에 한국어로 이모지와 함께 한 줄 설명을 Edit 도구로 기록합니다.
  - 작업 전에 `.commit_message.txt`를 읽고, 이후 Edit로 덮어쓰세요.
  - 기존 내용과 관계없이 항상 새 메시지로 완전히 덮어씁니다.
  - 의존성과 참조를 세심하게 확인하면서 진행합니다.
  - **커밋 메시지 앞에는 `[코덱스]`를 붙입니다.**
  - **커밋 메시지 마지막에는 현재 사용 중인 정확한 모델 ID를 포함합니다.**
  - git revert 관련 작업이라면 `.commit_message.txt` 파일을 비워둡니다.
* **⚠️ 필수: 모든 작업의 마지막 단계에서 렌더링 테스트를 실행하여 화면과 콘솔 오류가 없는지 확인합니다.**
  - PowerShell 예시: `start workflow.html`
  - 테스트 시 기본 브라우저에서 UI가 정상 표시되는지 확인하고, 개발자 도구(Console)에 오류가 없는지 점검합니다.
* **⚠️ 특히 중요: 파일 수정 알림(system-reminder)을 받으면 즉시 렌더링 테스트를 다시 수행합니다.**
* **🏗️ 렌더링 테스트가 모두 통과한 뒤에만** ntfy 알림 전송 및 git commit, push를 진행합니다.
* git commit 후에는 항상 강제 푸시(`git push --force`)로 원격 저장소를 최신 상태로 유지합니다.

### 한글 인코딩 정책 (Codex 특화)
**Codex는 한글 처리에 민감하므로 아래 규칙을 지킵니다.**
- 에이전트 커뮤니케이션(진행 멘트, 계획, 결과 요약, 제안, 질문)은 항상 한국어로 작성합니다.
- 도구 실행 전 안내, 계획, 최종 결과 메시지 모두 한국어로 제공합니다.
- 코드 변경 시 주석과 요약도 한국어를 기본으로 하고, 필요에 따라 영문을 병기합니다.
- 모든 텍스트 파일은 UTF-8(무 BOM)으로 저장하며, 콘솔 출력도 UTF-8로 맞춥니다.
  - PowerShell: `chcp 65001`, `[Console]::InputEncoding = [Text.UTF8]`, `[Console]::OutputEncoding = [Text.UTF8]`, `$OutputEncoding = [Text.UTF8]`
  - Git: `i18n.commitEncoding = utf-8`, `i18n.logOutputEncoding = utf-8`
- **중요**: PowerShell CLI에서 `Set-Content`, `Add-Content`, `Out-File`, 리다이렉션(`>`, `>>`)을 기본 옵션으로 실행하면 ANSI/UTF-16으로 저장되어 한글이 깨집니다. 항상 `-Encoding UTF8`을 지정합니다.
- Python 스크립트에서도 `encoding='utf-8'`을 명시합니다.
- 대량 치환이나 스크립트 실행 후에는 즉시 `git diff`로 한글이 깨지지 않았는지 점검합니다.
- 모든 스크립트 및 주요 산출물은 CRLF 줄바꿈을 유지합니다. 특히 workflow.html 수정 시 CRLF 유지 여부를 확인합니다.

### 작업 완료 알림 (Codex 전용)
**🚨 절대 필수 🚨: 모든 작업 완료 직전에 ntfy 알림을 반드시 전송해야 합니다!**

**⚠️ 한글 인코딩 보장을 위해 반드시 아래 방법을 사용하세요:**
- PowerShell의 `Invoke-RestMethod`는 한글이 깨져서 전송됩니다.
- 해결책: **Git Bash의 curl 사용** (`bash -c "curl ..."` 명령)

**전송 절차:**
1. **write 도구로 JSON 파일 생성** (UTF-8 인코딩 보장):
   ```json
   {
     "topic": "Workflow",
     "title": "[코덱스] 작업 완료",
     "message": "작업 요약: [실제 수행한 작업들의 구체적인 설명과 개선 효과]\n\n커밋 내역:\n- [커밋 메시지1]\n- [커밋 메시지2]",
     "priority": 4,
     "tags": ["checkmark", "AI", "chatGPT", "deep think", "complete"]
   }
   ```
   파일명: `temp_codex_final.json`

2. **bash + curl로 알림 전송** (PowerShell에서 실행):
   ```powershell
   bash -c "curl -H 'Content-Type: application/json; charset=utf-8' --data-binary @temp_codex_final.json https://ntfy.sh"
   ```

3. **임시 파일 정리** (PowerShell 명령):
   ```powershell
   Remove-Item -Force temp_codex_final.json
   ```

## 🚨🚨🚨 최종 강조사항 🚨🚨🚨
**모든 대화와 작업이 끝나기 직전에 반드시 ntfy 알림을 보내세요!**
작업 완료 → ntfy 알림 전송 → 대화 종료

### 임시 파일 및 로그 관리 (중요!)
- 프로젝트는 별도의 애플리케이션 로그 폴더를 쓰지 않습니다. 검증은 브라우저 개발자 도구(Console)의 메시지로 확인합니다.
- ntfy 전송 과정에서 생성되는 `temp_codex_final.json`을 즉시 삭제합니다.
- 루트 디렉터리에 남을 수 있는 `temp_*.json`, `*.log` 파일이 있다면 `rm -f temp_*.json *.log`로 정리합니다.
- `workflow.html`을 테스트한 후 브라우저 콘솔 오류가 남아 있지 않은지 확인합니다.

---

# 📋 PROJECT 정보 (AI 최적화 완전 통합 버전)

이 섹션은 Workflow Simulation 프로젝트의 기술 문서와 아키텍처 정보를 정리한 것입니다.

## 📋 AI_QUICK_REFERENCE (JSON 형태)

```json
{
  "workflow_project_complete": {
    "metadata": {
      "last_updated": "2025-10-07",
      "total_files": 10,
      "primary_artifact": "workflow.html",
      "app_type": "Single-page HTML Application"
    },
    "system_architecture": {
      "entry_point": "workflow.html",
      "core_runtime": "Vue.js 3 (CDN)",
      "supporting_libraries": ["html2canvas", "Feather Icons SVG", "Custom CSS"],
      "ui_layers": ["데이터 입력 패널", "단계 타임라인", "뷰포트(캔버스)", "디버그 레이어"]
    },
    "critical_dependencies": [
      "workflow.html ↔ Vue.createApp (전역 Vue 인스턴스 생성)",
      "workflow.html ↔ workflowSteps 데이터 배열",
      "workflow.html ↔ html2canvas (캔버스 스냅샷 기능)"
    ],
    "performance_hotspots": [
      "renderConnectorLines (라인 렌더링 연산)",
      "updateViewportBounds (뷰포트 크기 계산)",
      "watchers: selectedStage, selectedWorkflow (상호 연동)"
    ],
    "ai_search_tags": {
      "vue": ["Vue.createApp", "computed.filteredWorkflows", "watchers.selectedStage"],
      "ui": ["setupConnectorCanvas", "drawConnectorPaths", "layoutViewport"],
      "data": ["workflowSteps", "activeSelection", "transitionStates"]
    }
  }
}
```

## 프로젝트 개요
Workflow Simulation은 유지보수 절차를 단계별로 시각화하는 단일 HTML 페이지 애플리케이션입니다. Vue.js 3 CDN을 사용해 컴포넌트 없이 하나의 루트 인스턴스로 동작하며, 캔버스 및 SVG를 통해 단계 간 연결선을 실시간으로 렌더링합니다. 모든 자산(HTML, CSS, JavaScript)이 `workflow.html` 한 파일에 포함되어 있어 배포가 단순합니다.

## 실행 및 검증 절차
- **기본 실행**: `start workflow.html` (Windows) / `open workflow.html` (macOS) / `xdg-open workflow.html` (Linux)
- **변경 사항 확인**: 브라우저에서 단계를 전환하며 UI가 기대대로 반응하는지 확인합니다.
- **오류 점검**: F12 개발자 도구 Console 탭에서 JavaScript 오류가 없는지 확인합니다.
- **자동화 스크립트**: `cc.bat`는 Claude Code 도구 업데이트 및 실행을 위한 배치 파일입니다.
- 별도 빌드 파이프라인이 없으므로 커밋 전 렌더링 테스트가 곧 품질 검증입니다.

## 주요 파일과 스크립트
| 파일 | 용도 | 비고 |
| ---- | ---- | ---- |
| `workflow.html` | 메인 애플리케이션. HTML, CSS, JS가 모두 포함된 단일 파일 | 최신 버전을 편집 대상 기준으로 사용 |
| `workflow v0.5.html` | 참고용 이전 버전 스냅샷 | 비교 검토용. 직접 수정 금지 |
| `.commit_message.txt` | 커밋 메시지 임시 저장소 | 작업마다 덮어쓰기 |
| `cc.bat` | Claude Code 실행 스크립트 | `claude update && claude --dangerously-skip-permissions` |
| `gi.bat`, `gi.ps1`, `co.bat` | 저장소 관리 보조 스크립트 | 필요 시만 사용 |

## 아키텍처 하이라이트
- **데이터 모델**: `workflowSteps` 배열(약 864~975라인)이 각 워크플로우 스테이지와 하위 액션을 정의합니다. 선택 상태는 `selectedStageId`, `selectedWorkflowId`로 추적합니다.
- **상태 관리**: Vue 인스턴스의 `data`, `computed`, `watch` 구조를 사용합니다. `filteredWorkflows`, `activeStageDetails` 등이 UI에 즉시 반영됩니다.
- **렌더링 파이프라인**:
  1. `mounted` 훅에서 `setupConnectorCanvas()`로 SVG/캔버스를 초기화합니다.
  2. 뷰포트 크기가 변하면 `updateViewportBounds()`가 호출되어 드로잉 영역을 재계산합니다.
  3. 선택 변경 감시자에서 `renderConnectorLines()`를 실행하여 단계 간 연결선을 다시 그립니다.
  4. 디버그 레이어(`workflow-debug-layer`)는 `debugLayerVisible` 상태에 따라 표시되며 로그 복사, 초기화 기능을 제공합니다.
- **UI 컴포넌트 역할**:
  - `workflow-sidebar`: 워크플로우 목록 및 검색 필터 제공.
  - `workflow-stage-timeline`: 상단 단계 진행도 표시 및 클릭 이동.
  - `workflow-viewport`: 주요 다이어그램 영역. 드래그·휠 인터랙션을 지원합니다.
  - `workflow-modal`: 모바일/협업 공유용 전체 화면 레이어.

## 상호작용 및 UX 규칙
- **드래그 이동**: `.workflow-viewport` 영역에서 마우스를 드래그하면 콘텐츠가 스크롤됩니다. Ctrl+휠 입력은 가로 스크롤 속도를 2배로 가속합니다.
- **키보드 포커스**: 선택된 스테이지 변경 시 첫 번째 작업 항목에 포커스를 이동하여 키보드 내비게이션을 지원합니다.
- **애니메이션**: CSS `transition`을 활용하여 활성 단계가 부드럽게 확대(`scale(1)`)되며 비활성 상태는 `scale(0.6)`으로 축소됩니다.
- **디버그 기능**: `debugLayerVisible` 토글 시 실시간 로그 패널이 나타나며, 최근 1000개의 로그를 FIFO로 관리합니다.

## 개발 시 주의사항
1. **단일 파일 구조 유지**: `workflow.html` 내부 섹션(HTML/CSS/JS)이 명확히 구분되어 있으므로 섹션 순서를 임의로 변경하지 않습니다.
2. **CDN 의존성**: 인터넷 연결 없이 테스트할 경우 Vue.js 3, Feather Icons, html2canvas 로딩이 실패할 수 있으므로 사전 확인이 필요합니다.
3. **렌더링 성능**: `renderConnectorLines`는 DOM 측정을 반복하므로 불필요한 재호출을 피하고, 대량 변경 시 `requestAnimationFrame` 사용 패턴을 유지합니다.
4. **데이터 추가 가이드**: 워크플로우 단계 추가 시 `workflowSteps`에 객체를 삽입하고 `id`가 겹치지 않도록 관리합니다. 필요한 경우 SVG 커넥터 좌표도 함께 업데이트합니다.
5. **접근성**: 버튼과 링크에 `aria-label`을 유지하며, 색상 대비가 강한 테마 변수를 수정할 때는 `.workflow-theme` 관련 변수를 함께 조정합니다.

## 테스트 체크리스트
- UI 렌더링 시 주요 카드, 타임라인, 뷰포트가 모두 표시되는가?
- 단계 선택/검색/정렬 기능이 즉시 반응하는가?
- SVG 연결선이 올바른 위치에 그려지고 잔상이 남지 않는가?
- 브라우저 콘솔에 오류나 경고가 없는가?
- 디버그 레이어에서 로그 복사/초기화/닫기 동작이 정상적인가?

---

이 문서는 Codex CLI가 Workflow 프로젝트를 안정적으로 관리하기 위해 필요한 모든 지침과 참고 정보를 제공합니다. 항시 최신 상태를 유지하면서, 작업 시작 전 빠르게 훑어보고 지침을 준수하세요.
