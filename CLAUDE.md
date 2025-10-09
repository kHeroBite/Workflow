# CLAUDE.md - 워크플로우 시뮬레이션 프로젝트 매뉴얼

이 문서는 Claude Code가 Workflow 프로젝트에서 작업할 때 필요한 모든 정보를 포함합니다.

## ⚠️ 필수 작업 순서

```yaml
강제_작업_절차:
  1_빌드_테스트:
    명령어: start workflow.html
    설명: 브라우저에서_렌더링_테스트_실행
    목적: 화면과_콘솔_오류_확인

  2_문서_업데이트:
    조건: 중요한_변경_발생시
    대상: CLAUDE.md
    변경사항:
      - 새_파일_생성
      - 새_함수_추가
      - 주요_로직_변경
      - 아키텍처_변경
      - UI_컴포넌트_중요_변경
      - 공유_시스템_변경
      - 테마_시스템_변경
    자동_업데이트_규칙:
      - 위_조건_충족시_자동으로_CLAUDE.md_업데이트_실행
      - 변경_내용을_해당_섹션에_반영
      - 기존_구조_유지하면서_새_정보_추가

  3_커밋_준비:
    파일: .commit_message.txt
    형식: "[커서] {설명} by {modelId}"
    인코딩: UTF-8 (BOM 없음)
    순서:
      - Read .commit_message.txt
      - Edit .commit_message.txt (기존 내용 덮어쓰기)
    한글_인코딩_주의사항:
      - gpt-5 모델 사용 시 PowerShell 인코딩 문제 발생
      - 해결책: claude 모델만 사용 (한글 인코딩 문제 없음)
      - 모델_ID: claude 최신 버전 자동 사용

  4_git_작업:
    원격_저장소: https://github.com/kHeroBite/Workflow.git
    명령어:
      - git add .
      - git commit -m "[커서] {설명} by {modelId}" (직접 사용)
      - git push
    한글_인코딩_해결책:
      - claude 모델만 사용 (한글 인코딩 문제 없음)
      - .commit_message.txt 파일 정상 사용 가능
      - git commit -F .commit_message.txt 사용

  5_로그_삭제:
    명령어: rm -f temp_*.json *.log
    설명: 임시_파일_정리

  6_프로그램_실행:
    명령어: start workflow.html
    설명: 최종_렌더링_테스트

  7_ntfy_알림:
    필수: 절대_필수_절대_빠뜨리지_말것
    실행_시점: 모든_작업_완료_직전
    한글_인코딩_보장:
      - PowerShell Invoke-RestMethod는 한글 깨짐 발생
      - write 도구는 UTF-8 BOM을 추가하여 ntfy 서버가 거부
      - 해결: write 도구 + .NET API로 BOM 제거 + bash curl 전송
    명령어_순서:
      1. write 도구로 JSON 파일 생성 (단일 줄 압축):
         {"topic":"Workflow","title":"[커서] 작업 완료","message":"작업 요약...\n\n커밋 내역:\n- ...","priority":4,"tags":["checkmark","AI","chatGPT","deep think","complete"]}
         파일명: temp_cursor_final.json
      
      2. BOM 제거 (.NET API):
         [System.IO.File]::WriteAllText('C:\DATA\Project\Workflow\temp_cursor_final.json', (Get-Content 'C:\DATA\Project\Workflow\temp_cursor_final.json' -Raw), (New-Object System.Text.UTF8Encoding($false)))
      
      3. curl 전송:
         bash -c "curl -H 'Content-Type: application/json; charset=utf-8' --data-binary @temp_cursor_final.json https://ntfy.sh"
      
      4. 정리:
         Remove-Item -Force temp_cursor_final.json
    
    중요_참고:
      - write 도구와 PowerShell Set-Content는 항상 BOM 추가 → .NET API 필수
      - JSON은 단일 줄 압축 형식으로 작성 (줄바꿈 없음)
      - 전송 성공 시 응답 JSON에 한글 정상 표시 확인

완료_체크리스트:
  - 빌드_테스트_통과
  - 문서_업데이트_완료 (필요시)
  - 커밋_준비_완료
  - git_작업_완료
  - 로그_삭제_완료
  - 프로그램_실행_완료
  - ntfy_알림_전송됨
```

## 📦 프로젝트 메타데이터

```json
{
  "프로젝트명": "Workflow Simulation",
  "설명": "유지보수 워크플로우 시뮬레이션 애플리케이션",
  "개발자": "GPT-5",
  "프레임워크": "Vue.js 3",
  "프로젝트_타입": "Single-page HTML Application",
  "메인_파일": "workflow.html",
  "인코딩": "UTF-8 (무 BOM)",
  "총_파일수": 3,
  "주요_라이브러리": ["Vue.js 3", "html2canvas"]
}
```

## 📁 전체 파일 인벤토리 (3개)

### 1️⃣ 메인 애플리케이션 파일

```yaml
메인_파일:
  - 파일명: workflow.html
    경로: workflow.html
    중요도: ★★★★★
    역할: 단일 파일 Vue.js 3 애플리케이션
    라인수: ~1800
    구조:
      - HTML: 구조 정의 (lines 745-854)
      - CSS: 테마 및 스타일링 (lines 7-742)
      - JavaScript: Vue.js 로직 (lines 856-1776)
```

### 2️⃣ 헬퍼 스크립트

```yaml
헬퍼_파일:
  - 파일명: cc.bat
    경로: cc.bat
    역할: Claude Code 실행 스크립트
    내용: "claude update && claude --dangerously-skip-permissions"
```

### 3️⃣ 문서 파일

```yaml
문서_파일:
  - 파일명: AGENTS.md
    경로: AGENTS.md
    역할: Codex CLI 전용 설정 (한국어 작업 지침)
```

## 🏗️ 프로젝트 아키텍처

This is a **maintenance workflow simulation application** built as a single-page HTML/CSS/JavaScript application using Vue.js 3. The workflow dynamically visualizes multi-step maintenance processes with interactive stage selections and animated connector lines.

```yaml
아키텍처_계층:
  레이어1_HTML구조:
    - 단일_파일_애플리케이션: workflow.html (~1800 lines)
    - Vue.js_3_마운트: .page 클래스
    - CDN_라이브러리:
      - Vue.js 3 (unpkg.com)
      - html2canvas 1.4.1 (cdnjs.cloudflare.com)

  레이어2_상태관리:
    - workflowSteps: 워크플로우 단계 배열 (lines 864-975)
    - selections: 사용자 선택 추적 객체 { stageId: itemId }
    - visibleStages: 동적 계산된 표시 단계
    - lines: SVG 연결선 경로 배열

  레이어3_핵심_컴포넌트:
    - 워크플로우_상태관리: Vue.js data() 반응형 시스템
    - 동적_단계_렌더링: nextSteps 속성 기반
    - SVG_연결선_시스템: Bezier 곡선 경로 계산
    - 뷰포트_줌_제어: CSS transform 스케일링

  레이어4_사용자_인터페이스:
    - 툴바: 테마 전환, 줌 컨트롤, 이미지 저장
    - 진행도_바: 단계 선택 진행률 표시
    - 워크플로우_보드: 드래그 가능한 캔버스
    - 단계_카드: 선택 옵션 및 연결선

의존성_관계:
  강한_결합:
    - handleSelection() → updateConnections(): 선택 시 연결선 재계산
    - updateConnections() → getBoundingClientRect(): 좌표 계산
    - saveAsImage() → html2canvas: 이미지 내보내기
    - theme 변경 → CSS 커스텀 속성: 테마 시스템

  초기화_순서:
    1. Vue.createApp() 마운트
    2. localStorage에서 테마 로드
    3. 이벤트 리스너 등록 (resize, drag)
    4. 사용자가 "시작" 버튼 클릭
    5. startFlow() → 첫 단계 표시
    6. handleSelection() → 다음 단계 동적 추가
    7. updateConnections() → SVG 연결선 생성

핵심_경로:
  상태_저장:
    LocalStorage_키: "maintenanceWorkflowTheme"
    저장_데이터: "light" | "dark"

  이미지_캡처:
    영역: .workflow-stage-list
    여유공간: left=20px, top=50px, right=50px, bottom=-50px
    스케일: 2 (고해상도)
    형식: PNG
```

## 🔍 주요 함수 및 메서드

```yaml
핵심_computed_속성:
  - 속성명: expectedMaxSteps
    역할: 현재 경로의 예상 최대 단계 수 동적 계산 (단조 증가)
    반환값: Number (최소 5 ~ 최대 7)
    동작:
      - visibleStages가 비어있으면 → 7 (전체 단계)
      - 마지막 단계가 7(완료)면 → visibleStages.length
      - 그 외 → 마지막 선택의 nextSteps 파싱 후 남은 최대 거리 계산
      - Math.max()로 maxExpectedSteps와 비교하여 절대 감소하지 않음 (진행도 안정성)
    호출: progressRatio에서 사용
    개선사항:
      - 진행도 바가 역행하는 버그 해결 (maxExpectedSteps 추적)
      - 7단계 완료 시 100% 표시 수정

  - 속성명: calculateMaxDistanceToCompletion(stageId)
    역할: 주어진 단계에서 완료까지의 최대 거리
    반환값: Number (1~5)
    매핑:
      - 1단계 → 5 (1→2→4→5.1→7)
      - 2단계 → 4 (2→4→5.1→7)
      - 5단계 → 3 (5→6→7)
      - 6단계 → 2 (6→7)
      - 7단계 → 1 (완료)

  - 속성명: progressRatio
    역할: 진행률 계산 (0~1)
    변경: selectedCount / workflowSteps.length → selectedCount / expectedMaxSteps
    효과: 경로별 정확한 진행률 표시 (완료 시 항상 100%)

핵심_함수:
  - 함수명: onSliderChange()
    역할: 줌 슬라이더 값 변경 처리
    동작:
      - isFit = false 설정
      - linesFlowEnabled = true
      - updateConnections(true) 호출
    호출위치: 슬라이더_@input_이벤트

  - 함수명: handleSliderMarkerClick(event)
    역할: 슬라이더 100% 마커 클릭 처리
    동작:
      - 클릭 위치 계산 (clientX - rect.left)
      - 100% 위치: (1.0 - 0.1) / (2.0 - 0.1) * 120px = 56.84px
      - 마커 근처 (±10px) 클릭 시 scale = 1.0 설정
      - updateConnections(true) 호출
    호출위치: .zoom-slider-wrapper @click 이벤트

  - 함수명: startFlow()
    역할: 워크플로우 초기화
    동작:
      - started = true 설정
      - 첫 번째 단계만 visibleStages에 추가
      - selections, lines 초기화
      - 첫 옵션에 포커스
    호출위치: 시작_버튼_클릭_시

  - 함수명: handleSelection(visibleStageIndex, item)
    역할: 사용자 선택 처리 및 다음 단계 결정
    매개변수:
      - visibleStageIndex: 현재 단계 인덱스
      - item: 선택된 항목 객체
    동작:
      - selections에 현재 선택 저장
      - 이후 단계 선택 제거
      - 이후 화살표 제거 (현재 단계로 들어오는 화살표 유지)
      - parseNextSteps()로 다음 단계 파싱
      - 이전 단계 재선택 시: 건너뛰는 단계(예: 5→9) 감지하여 현재+1 단계만 추가 (갑작스러운 완료 단계 방지)
      - 정상 진행 시: 모든 다음 단계 추가 (건너뛰기 허용)
      - 캔버스 크기 업데이트 (visibleStages × 346px)
      - updateConnections(false) 호출
      - resetZoom() + scrollToRight()
    호출빈도: 매_선택마다 (사용자_인터랙션)
    버그수정:
      - 이전 단계 재선택 시 완료 단계가 갑자기 나타나는 문제 해결
      - isBackNavigation 플래그로 뒤로 가기 감지, 건너뛰기 발생 시 순차 진행 강제

  - 함수명: updateConnections(forceRecalculate)
    역할: SVG 연결선 경로 재계산
    매개변수:
      - forceRecalculate: true면 전체 재계산, false면 기존 화살선 유지
    동작:
      - stageListWrapper 크기 설정 (stageCount × 356px)
      - getBoundingClientRect()로 좌표 계산
      - scaleFactor로 역보정 (비스케일 좌표)
      - 기존 화살선 유지 시 애니메이션 상태 업데이트 (flow: true, draw: false)
      - Bezier 곡선 경로 생성 (M, C 명령)
      - SVG 크기 계산 (connectorSize)
      - lines 배열 업데이트
    호출빈도: 선택_시, 줌_변경_시, 리사이즈_시
    개선사항:
      - 기존 화살선도 flow 속성 업데이트 → 애니메이션 유지
      - draw: false로 설정 → 그리기 애니메이션 제거, 흐름만 유지
    버그수정:
      - 이전 단계 재선택 시 화살선 점선 사라지는 문제 해결 (2가지 수정)
      - 1) 화살선 제거 조건 수정: fromStageId >= → fromStageId > (현재→다음 화살선 유지)
      - 2) 화살선 그리기 조건: 양쪽 모두 선택되어 있어야 함 (자동 연결 방지)

  - 함수명: parseNextSteps(nextStepsStr)
    역할: nextSteps 문자열 파싱
    매개변수:
      - nextStepsStr: "2" 또는 "3.1, 3.2, 3.3" 형태
    반환값:
      - [{ stageId: 3, itemIds: ['3.1', '3.2'] }] 형태
    동작:
      - 쉼표로 분리 후 단계별 그룹화
      - Map으로 중복 제거 및 정렬
    호출빈도: 매_선택마다

  - 함수명: fitToView()
    역할: 전체 보기 모드 (뷰포트에 맞춤)
    동작:
      - 스케일 1로 리셋
      - scrollWidth/scrollHeight 측정
      - 뷰포트 크기 대비 최적 스케일 계산 (96% 여유)
      - scale 적용 (0.3~1.5 범위)
      - isFit = true 설정
      - 스크롤 위치 (0,0)으로 리셋
      - updateConnections(true) 호출
    호출빈도: 전체보기_버튼_클릭_시

  - 함수명: saveAsImage()
    역할: 워크플로우 이미지 내보내기
    동작:
      - stageListWrapper 영역 캡처
      - html2canvas로 DOM → Canvas 변환
      - 여유 공간 추가 (좌=20, 상=50, 우=50, 하=-50)
      - scale=2 (고해상도)
      - Canvas → Blob → PNG 다운로드
      - 파일명: workflow-{timestamp}.png
      - 디버그 로그 기록 (성공/실패)
    호출빈도: 이미지_저장_버튼_클릭_시

  - 함수명: toggleDebugLayer()
    역할: 디버그 레이어 표시/숨김
    동작:
      - debugLayerVisible 토글 (true ↔ false)
      - 디버그 로그 기록 (열림/닫힘)
    호출빈도: 디버그_버튼_클릭_시

  - 함수명: logAction(message)
    역할: 디버그 로그 기록
    매개변수:
      - message: 로그 메시지 문자열
    동작:
      - 현재 시간 포맷팅 (YYYY-MM-DD HH:MM:SS.mmm)
      - debugLogs 배열에 추가 { time, message }
      - 1000개 제한 (FIFO 방식으로 가장 오래된 로그 제거)
      - $nextTick으로 로그 컨테이너 자동 스크롤
    호출빈도: 모든_주요_액션마다
    로그_대상:
      - 테마 변경 (라이트/다크)
      - 워크플로우 시작/리셋
      - 단계 선택 (선택 항목, 다음 단계 정보)
      - 화살선 생성/제거 (좌표, ID)
      - 줌 변경 (스케일 값)
      - 이미지 저장 (성공/실패)
      - 드래그 시작/종료
      - 디버그 레이어 토글
      - 로그 복사/초기화

  - 함수명: copyDebugLogs()
    역할: 디버그 로그 클립보드 복사
    동작:
      - debugLogs 배열을 텍스트로 변환 (시간 + 메시지)
      - navigator.clipboard.writeText() 사용
      - 성공 시: alert + 디버그 로그 기록
      - 실패 시: console.error + alert
    호출빈도: 복사_버튼_클릭_시
    async: true (비동기 함수)

  - 함수명: clearDebugLogs()
    역할: 디버그 로그 초기화
    동작:
      - debugLogs 배열 비우기
      - 디버그 로그 기록 (초기화됨)
    호출빈도: 초기화_버튼_클릭_시

  - 함수명: resetFlow()
    역할: 워크플로우 완전 초기화
    동작:
      - started = false
      - maxExpectedSteps = 9 (진행도 계산 리셋)
      - debugLayerVisible = false (디버그 레이어 자동 닫기)
      - selections, visibleStages, lines 초기화
      - scale = 1, isFit = false
      - 스크롤 (0, 0)
      - 디버그 로그 기록
    호출빈도: 처음으로_버튼_클릭_시

  - 함수명: shareWorkflow()
    역할: 워크플로우 이미지 공유 준비
    동작:
      - captureWorkflowImage()로 PNG 생성
      - tryShareWithNativeAPI()로 Web Share API 시도
      - 실패 시 공유 센터 열기
      - shareCenter.dataUrl, filename, message 설정
    호출빈도: 공유_버튼_클릭_시
    위치: workflow.html:2801

  - 함수명: generateTextDiagram()
    역할: 워크플로우 상태를 텍스트 다이어그램으로 변환
    반환값: string (텍스트 형식의 워크플로우 다이어그램)
    동작:
      - 상단 여백 2줄 추가 (서명과 구분)
      - 구분선: ━━ (50개 반복)
      - 각 단계별 진행 내역 표시
      - 진행률 및 생성 시각 포함
    호출빈도: 텍스트 공유 시
    개선사항:
      - 서명 위 붙여넣기 위한 상단 여백 추가
      - 구분선 스타일 개선 (━ 사용)

  - 함수명: shareViaEmail()
    역할: 메일 공유 (이미지 공유 탭용)
    동작:
      - 텍스트 다이어그램 생성
      - 이메일 본문에 다이어그램 + 이미지 첨부 안내
      - PNG 이미지 자동 다운로드
    호출빈도: 이미지 공유 탭의 메일 버튼 클릭 시
    async: true (비동기 함수)

  - 함수명: shareViaEmailText()
    역할: 메일 공유 (텍스트 공유 탭용)
    동작:
      - 텍스트 다이어그램을 클립보드에 복사
      - 빈 이메일 클라이언트 열기
      - 사용자가 서명 위에 붙여넣기 안내
    호출빈도: 텍스트 공유 탭의 메일 버튼 클릭 시
    async: true (비동기 함수)

  - 함수명: handleShareTarget(targetId)
    역할: 공유 대상별 액션 분기
    매개변수:
      - targetId: 'email' | 'kakao' | 'sms' | 'sns'
    동작:
      - email: 활성 탭에 따라 분기
        - 이미지 탭: shareViaEmail() 호출
        - 텍스트 탭: shareViaEmailText() 호출
      - kakao: shareViaKakao() 호출 (메시지 복사)
      - sms: shareViaSMS() 호출 (sms: 프로토콜)
      - sns: shareViaSNS() 호출 (Twitter 공유)
    호출빈도: 공유_센터_옵션_클릭_시
    위치: workflow.html:2945
    개선사항:
      - 탭별 이메일 공유 방식 분리

  - 함수명: getSystemPreferredTheme()
    역할: 시스템(브라우저/OS) 선호 테마 감지
    반환값: 'light' | 'dark'
    동작:
      - window.matchMedia('(prefers-color-scheme: dark)') 확인
      - 다크 모드 감지 시 'dark' 반환
      - 기본값: 'light' 반환
    호출빈도: 최초 실행 시 (mounted 훅)
    개선사항:
      - Windows/브라우저 시스템 테마 자동 감지

  - 함수명: buildShareMessage(filename)
    역할: 공유 메시지 생성
    매개변수:
      - filename: PNG 파일명
    반환값: 공유용 텍스트 메시지 (줄바꿈 포함)
    내용:
      - "Workflow 시뮬레이션 이미지를 공유합니다."
      - 파일명, 현재 단계, 선택 개수, 타임스탬프
    호출빈도: shareWorkflow() 내부
    위치: workflow.html:2879
```

## 📊 데이터 구조

```javascript
// 워크플로우 단계 구조
workflowStep = {
  id: 1,                          // 단계 번호
  title: '유입경로',              // 단계 제목 (한국어)
  items: [
    {
      id: '1.1',                  // 항목 ID (stage.item 형식)
      label: '전화',              // 표시 라벨
      nextSteps: '2'              // 다음 단계 ("2" 또는 "3.1, 3.2")
    }
  ]
}

// 표시 단계 구조
visibleStage = {
  stage: workflowStep,            // 원본 단계 객체
  visibleItems: [...]             // 표시할 항목 배열 (필터링됨)
}

// 연결선 구조
line = {
  id: 'line-1-to-2',              // 연결선 ID
  stageIndex: 0,                  // 시작 단계 인덱스
  startX: 400,                    // 시작 X 좌표 (비스케일)
  startY: 150,                    // 시작 Y 좌표
  endX: 800,                      // 끝 X 좌표
  endY: 180,                      // 끝 Y 좌표
  controlPoint1X: 520,            // 제어점1 X
  controlPoint1Y: 150,            // 제어점1 Y
  controlPoint2X: 680,            // 제어점2 X
  controlPoint2Y: 180,            // 제어점2 Y
  path: 'M 400 150 C ...',        // SVG 경로
  active: true,                   // 활성화 여부
  flow: true,                     // 흐름 애니메이션
  draw: true,                     // 그리기 애니메이션
  cssClassFlow: 'has-flow',       // CSS 클래스
  cssClassDraw: 'animate-draw'    // CSS 클래스
}

// 디버그 로그 구조
debugLog = {
  time: '2025-10-04 14:23:45.123', // 타임스탬프 (밀리초 포함)
  message: '액션 설명'             // 로그 메시지
}

// Vue 상태 (디버그 관련)
data() {
  return {
    debugLayerVisible: false,     // 디버그 레이어 표시 여부
    debugLogs: [],                // 디버그 로그 배열 (최대 1000개)
    maxExpectedSteps: 9,          // 진행도 계산용 (단조 증가)
    // ... 기타 상태들
  }
}

// 공유 센터 상태
shareCenter = {
  visible: false,                 // 공유 센터 표시 여부
  dataUrl: '',                    // PNG 이미지 데이터 URL
  filename: '',                   // PNG 파일명 (workflow-timestamp.png)
  message: '',                    // 공유 메시지 텍스트
  downloadPrepared: false         // 이미지 다운로드 완료 여부
}

// 공유 대상 목록
shareTargets = [
  {
    id: 'email',
    label: '메일 보내기',
    description: '이미지와 메시지를 메일로 공유 (지원 시 자동 첨부, 미지원 시 수동 첨부)'
  },
  {
    id: 'kakao',
    label: '카카오톡',
    description: '메시지를 복사해 카카오톡 대화창에 붙여넣고 이미지 첨부'
  },
  {
    id: 'sms',
    label: '문자 메시지',
    description: '모바일 문자 앱에서 메시지와 이미지 공유'
  },
  {
    id: 'sns',
    label: 'SNS 공유',
    description: 'Twitter 등 SNS 공유 창 열기 또는 메시지 복사'
  }
]
```

## 💬 툴팁 시스템

```yaml
구현_방식:
  클래스: has-tooltip
  속성: data-tooltip="툴팁_텍스트"

CSS_구조:
  툴팁_박스 (::after):
    - content: attr(data-tooltip)
    - 위치: bottom: calc(100% + 8px)
    - 배경: rgba(0, 0, 0, 0.9)
    - 패딩: 0.45rem 0.9rem
    - 폰트: 0.8rem, 500 두께
    - 테두리: 8px 둥근 모서리
    - z-index: 999999 (최상위)
    - 애니메이션: opacity + transform (0.2s)

  툴팁_화살표 (::before):
    - 위치: bottom: calc(100% + 2px)
    - 삼각형: border 6px
    - 색상: rgba(0, 0, 0, 0.9)
    - z-index: 999999 (최상위)

  인터랙션:
    - 기본: opacity 0, 숨김
    - 호버/포커스: opacity 1, 표시
    - 트리거: :hover, :focus-visible (is-active 제거됨)
    - 애니메이션: translateY(4px) → 0

  버그수정:
    - 테마 버튼의 ::after 충돌 문제 해결 - 펄스 애니메이션 제거
    - is-active 트리거 제거 - 선택된 테마도 호버 시에만 툴팁 표시

적용_대상:
  - 테마_버튼 (라이트/다크) - 선택된 테마도 툴팁 표시
  - 처음으로_버튼 (resetFlow)
  - 이미지_저장_버튼 (PNG 내보내기)
  - 전체보기_버튼
  - 축소_버튼
  - 기본_크기_버튼
  - 확대_버튼
  - 디버그_버튼 (디버그 로그 토글)
```

## 🎨 테마 시스템

```yaml
테마_변수:
  다크_테마:
    배경: --body-background (radial-gradient)
    텍스트: --text-primary (#f5f5f5)
    카드: --bg-card (linear-gradient)
    강조: --accent-strong (#fcd34d)
    커넥터: url(#connectorGradient)

  라이트_테마:
    배경: --body-background (radial-gradient)
    텍스트: --text-primary (#1f2937)
    카드: --bg-card (linear-gradient)
    강조: --accent-strong (#c2410c)
    커넥터: url(#connectorGradient)

CSS_커스텀_속성:
  크기_관련:
    --stage-width-base: clamp(312px, 28.6vw, 390px)
    --summary-height-base: clamp(96px, 13vw, 132px)
    --choice-height-base: clamp(42px, 5vw, 56px)
    --board-gap-base: clamp(0.6rem, 2vw, 1rem)
    --workflow-scale: 1 (동적 변경)

  고정_크기:
    단계_너비: 346px (단계당 고정 너비)
    캔버스_너비: visibleStages.length × 346px

시스템_테마_감지:
  초기_테마_결정:
    - localStorage에 저장된 테마 우선 적용
    - 없으면 시스템 선호 테마 감지 (prefers-color-scheme: dark)
    - getSystemPreferredTheme() 메서드로 자동 감지
  저장_키: "maintenanceWorkflowTheme"
  지원_브라우저: Chrome, Edge, Firefox, Safari
```

## 🎯 중요 구현 세부사항

```yaml
단계_너비_계산:
  고정_너비: 346px (단계당 고정 너비)
  총_캔버스_너비: visibleStages.length × 346px
  명시적_설정_위치:
    - handleSelection() line 1313: const stageWidth = 346
    - updateConnections() line 1431: const stageWidth = 346
    - updateConnections() line 1442: calculatedWidth = stageCount * 346
    - updateConnections() line 1549: calculatedWidth = stageCount * 346

연결선_좌표_계산:
  메서드: getBoundingClientRect()
  보정: scaleFactor로 역보정 (비스케일 좌표)
  공식: (rect - containerRect) / scaleFactor
  중요: SVG viewBox는 계산된 캔버스 크기와 일치

선택_플로우_로직:
  이전_단계_재선택:
    - 현재 단계 이후 selections 제거
    - 현재 단계 이후 화살표 제거
    - 현재 단계까지만 visibleStages 유지
    - 다음 단계 추가 (최대 현재+1까지)

  다음_단계_선택:
    - 자동_스크롤: scrollToRight() (우측 끝으로)
    - 자동_줌리셋: resetZoom() (100%로)
    - 포커스_이동: 다음 단계 첫 옵션

뷰포트_제어:
  줌_범위: 30%~150%
  전체보기_모드:
    - 스크롤_비활성화
    - 드래그_비활성화
    - 휠_이벤트_차단
  드래그_모드:
    - 마우스_드래그로_팬
    - 인터랙티브_요소_제외
  휠_스크롤:
    - 기본: 좌우_스크롤
    - Ctrl+휠: 빠른_좌우_스크롤
```

## 🎬 애니메이션 시스템

```yaml
연결선_애니메이션:
  그리기_애니메이션:
    클래스: animate-draw
    효과: pathLength 100 → 0 (1.2s)
    타이밍: 선택_직후_1회
    키프레임: connectorDraw (lines 680-686)

  흐름_애니메이션:
    클래스: has-flow
    효과: stroke-dashoffset 0 → -10 (2s 무한)
    타이밍: 그리기_완료_후_무한반복
    키프레임: connectorFlow (lines 689-695)

  점선_패턴:
    stroke-dasharray: 6 4 (pathLength 기반)
    일관성: 모든 선에서 동일한 간격

줌_변경_시:
  그리기_애니메이션: 비활성화
  흐름_애니메이션: 유지 (linesFlowEnabled=true)
  좌표_재계산: updateConnections(true)
```

## 📝 프로젝트 요구사항 및 설계 철학

```yaml
핵심_요구사항:
  최종물_형태:
    - 단일_파일: workflow.html 하나로 완결
    - 외부_의존성: CDN만 사용 (빌드 시스템 없음)
    - 배포_방식: 파일_복사만으로_즉시_실행
    - 브라우저_실행: 별도_서버_불필요

  기술_스택:
    현대적_UI_프레임워크:
      - Vue.js 3: 반응형 상태 관리
      - Options API: 직관적인 컴포넌트 구조
      - Reactive Data: 실시간 UI 업데이트

    고급_UI_기술:
      - CSS Custom Properties: 동적 테마 시스템
      - SVG Graphics: 벡터 기반 연결선
      - Canvas API: 이미지 내보내기
      - Transform 3D: 부드러운 줌/스케일
      - Gradient Animation: 시각적 효과

  비즈니스_목적:
    유지보수팀_의사결정_자동화:
      - 유입_경로_분석: 8가지 채널 (전화, 메일, 헬프데스크 등)
      - 요구사항_분류: 16가지 유형 (장애, PM, Q&A 등)
      - 세부_유형_판정: 12가지 소분류
      - 유무상_결정: 계약 여부에 따른 자동 판단
      - 작업_방식_배정: 담당자/팀장/본부장 보고 체계
      - 채널_구분: 내부/외부/영업 프로세스
      - 최종_완료: 리포트 및 이력 저장

    의사결정_트리_시각화:
      - 실시간_경로_추적: 선택에 따른 동적 단계 표시
      - 연결선_표시: Bezier 곡선으로 선택 흐름 시각화
      - 진행률_추적: 전체 9단계 중 현재 위치 표시
      - 이미지_내보내기: 의사결정 결과 PNG 저장

설계_철학:
  단일_파일_구조:
    이점:
      - 배포_간편성: 파일 하나만 전송
      - 버전_관리: Git에서 단일 파일 추적
      - 의존성_제로: node_modules 불필요
      - 오프라인_동작: 인터넷 연결 없이도 실행

    구현_전략:
      - 인라인_CSS: <style> 태그 내 임베드
      - 인라인_JS: <script> 태그 내 Vue 앱
      - CDN_라이브러리: unpkg.com (Vue, html2canvas)
      - 자체_포함_데이터: workflowSteps 배열

  반응형_상태_관리:
    Vue.js_장점:
      - 선언적_렌더링: v-for, v-if로 동적 UI
      - 양방향_바인딩: v-model, :class, :style
      - 계산된_속성: computed로 파생 상태
      - 감시자: watch로 테마 변경 감지
      - 생명주기: mounted/beforeUnmount 훅

  사용자_경험:
    인터랙션_디자인:
      - 드래그_팬: 마우스로 캔버스 이동
      - 휠_스크롤: 수평 스크롤 (Ctrl+휠로 가속)
      - 줌_컨트롤: 30%~150% 자유 조절
      - 전체보기: 한 번에 모든 단계 표시
      - 키보드_네비게이션: 포커스 자동 이동

    시각적_피드백:
      - 테마_전환: 라이트/다크 모드 (localStorage 저장)
      - 애니메이션: 연결선 그리기 + 흐름 효과
      - 진행률_바: 그라디언트 바로 진행 상황 표시
      - 선택_강조: is-selected, is-active 클래스
```

## ⚙️ 실행 및 개발

```bash
# 브라우저에서 직접 실행 (빌드 불필요)
open workflow.html          # macOS
start workflow.html         # Windows
xdg-open workflow.html      # Linux

# Claude Code 실행
./cc.bat                    # Windows
# 내용: claude update && claude --dangerously-skip-permissions

# Git 작업
git add .
git commit -F .commit_message.txt
git push

# 원격 저장소
# https://github.com/kHeroBite/Workflow.git
```

## 🔧 일반적인 유지보수 작업

```yaml
워크플로우_단계_추가:
  위치: workflowSteps 배열 (lines 864-975)
  작업:
    1. 새_단계_객체_추가:
       {
         id: 10,
         title: '새로운_단계',
         items: [
           { id: '10.1', label: '옵션1', nextSteps: '' }
         ]
       }
    2. 기존_단계의_nextSteps_업데이트:
       { id: '9.1', label: '완료', nextSteps: '10' }

연결선_스타일_수정:
  그라디언트_색상 (lines 815-822):
    <linearGradient id="connectorGradient">
      <stop offset="0%" stop-color="#3b82f6" />
      <!-- 색상_변경 -->
    </linearGradient>

  애니메이션_속도:
    - connectorDraw (line 680): 1.2s → 변경
    - connectorFlow (line 689): 2s → 변경

  선_굵기_및_패턴:
    - stroke-width: 4 (line 642)
    - stroke-dasharray: 6 4 (line 647)

단계_카드_크기_조정:
  CSS_변수_수정 (lines 8-21):
    --stage-width-base: clamp(312px, 28.6vw, 390px)
    --summary-height-base: clamp(96px, 13vw, 132px)
    --choice-height-base: clamp(42px, 5vw, 56px)

  고정_너비_상수_변경:
    - handleSelection() line 1313: const stageWidth = 346
    - updateConnections() line 1431: const stageWidth = 346
    - updateConnections() line 1442: calculatedWidth = stageCount * 346
    - updateConnections() line 1549: calculatedWidth = stageCount * 346
    - 주의: 모든_위치_동시_변경_필수 (현재 346px)

테마_커스터마이징:
  다크_테마 (lines 28-81):
    body[data-theme="dark"] {
      --bg: #0a0a0a;
      --text-primary: #f5f5f5;
      <!-- 색상_변경 -->
    }

  라이트_테마 (lines 83-136):
    body[data-theme="light"] {
      --bg: #f8fafc;
      --text-primary: #1f2937;
      <!-- 색상_변경 -->
    }

새_기능_추가_가이드:
  Vue_메서드_추가:
    위치: methods 객체 (lines 1104-1772)
    패턴:
      methodName() {
        // 구현
        this.$nextTick(() => {
          // DOM 업데이트 후 실행
        });
      }

  Vue_계산된_속성_추가:
    위치: computed 객체 (lines 1004-1074)
    패턴:
      propertyName() {
        return /* 계산_로직 */;
      }

  이벤트_리스너_추가:
    mounted() 훅 (lines 1081-1097):
      window.addEventListener('이벤트명', this.핸들러);
    beforeUnmount() 훅 (lines 1098-1103):
      window.removeEventListener('이벤트명', this.핸들러);

디버깅_가이드:
  디버그_레이어_사용:
    활성화: 툴바의 벌레 아이콘 클릭 (확대 버튼 우측)
    기능:
      - 실시간_로그_확인: 모든 사용자 액션 및 시스템 이벤트 추적
      - 로그_복사: "복사" 버튼으로 전체 로그를 클립보드에 복사 (Claude에게 공유)
      - 로그_초기화: "초기화" 버튼으로 로그 비우기
      - 자동_닫기: "처음으로" 버튼 클릭 시 자동으로 닫힘
    활용:
      - 버그_재현_과정_기록
      - 성능_이슈_분석 (시간 측정)
      - 사용자_행동_추적
      - Claude에게_문제_상황_공유

  로그_추가_방법:
    기존_메서드에_추가:
      this.logAction('액션_설명: 추가_정보');

    예시:
      // 테마 변경 시
      this.logAction(`테마 변경: ${this.theme === 'dark' ? '다크 모드' : '라이트 모드'}`);

      // 단계 선택 시
      this.logAction(`단계 ${stage.id} 선택: ${item.label} (다음: ${item.nextSteps || '없음'})`);

      // 화살선 생성 시
      this.logAction(`화살선 생성: ${lineId} (${startX},${startY} → ${endX},${endY})`);

  디버그_팁:
    - 복잡한_버그: 로그를 복사하여 Claude에게 공유하면 빠른 분석 가능
    - 성능_측정: 로그의 밀리초 타임스탬프로 작업 소요 시간 계산
    - 순서_확인: 이벤트 발생 순서를 타임스탬프로 정확히 추적
```

## 🧪 테스트 체크리스트

```yaml
기능_테스트:
  ✓ 단계_네비게이션:
    - 첫_단계부터_끝까지_선택_가능
    - 이전_단계_재선택_시_후속_단계_제거
    - nextSteps_파싱_정확성 ("2", "3.1, 3.2" 형식)

  ✓ 연결선_렌더링:
    - 선택_시_Bezier_곡선_생성
    - 줌_변경_시_좌표_재계산
    - 리사이즈_시_연결선_업데이트
    - 그리기_애니메이션_1회_실행
    - 흐름_애니메이션_무한_반복

  ✓ 줌_컨트롤:
    - 확대/축소_버튼 (30%~150%)
    - 전체보기_자동_스케일_계산
    - 기본_크기_리셋 (100%)
    - 드래그_팬_동작
    - 휠_스크롤 (기본/Ctrl)

  ✓ 테마_시스템:
    - 라이트/다크_전환
    - localStorage_저장/로드
    - 페이지_새로고침_후_테마_유지

  ✓ 이미지_내보내기:
    - PNG_파일_다운로드
    - 타임스탬프_파일명
    - 고해상도_렌더링 (scale=2)
    - 여유_공간_포함

  ✓ 디버그_시스템:
    - 디버그_버튼_토글 (레이어 표시/숨김)
    - 모든_액션_로그_기록 (테마, 선택, 줌, 드래그 등)
    - 타임스탬프_정확성 (밀리초 포함)
    - 로그_복사_기능 (클립보드)
    - 로그_초기화_기능
    - 자동_스크롤 (최신 로그로)
    - 1000개_제한 (FIFO 제거)
    - "처음으로" 클릭_시_자동_닫기
    - is-active 상태_표시 (펄스 애니메이션)
    - 닫기_버튼_동작

  ✓ 진행도_바:
    - 툴바_배경_그라디언트_표시
    - 단계_선택_시_증가 (0~100%)
    - 진행도_역행_방지 (단조 증가)
    - 경로별_정확한_진행률
    - 완료_시_100%_도달

  ✓ 처음으로_버튼:
    - 워크플로우_초기화
    - 디버그_레이어_자동_닫기
    - 진행도_리셋
    - started=false 시_비활성화

성능_테스트:
  ✓ 대량_단계_처리:
    - 9단계_x_평균_8개_옵션 = 72개_항목
    - 연결선_최대_8개_동시_렌더링
    - 60fps_유지 (애니메이션)

  ✓ 메모리_관리:
    - 이전_단계_제거_시_lines_배열_정리
    - SVG_요소_재사용
    - 이벤트_리스너_정리 (beforeUnmount)

반응형_테스트:
  ✓ 브라우저_호환성:
    - Chrome/Edge (권장)
    - Firefox
    - Safari

  ✓ 화면_크기:
    - 데스크톱 (1920px+)
    - 태블릿 (768px~1080px)
    - 모바일 (720px 이하)

  ✓ 접근성:
    - aria-label, aria-live 속성
    - 키보드_네비게이션
    - prefers-reduced-motion 지원
```

## 📝 코드 컨벤션

```yaml
언어_규칙:
  UI_텍스트: 한국어 (사용자_대면)
  코드_내부: 영어 (변수명, 함수명)
  주석: 한국어 (설명)
  커밋_메시지: "[클로드] {이모지} {설명} (model-name)"

파일_인코딩:
  문자셋: UTF-8 (무 BOM)
  줄_끝: LF (Git 자동 변환)

CSS_방법론:
  네이밍: BEM-like (workflow-stage__title)
  테마: CSS Custom Properties (--변수명)
  반응형: clamp() 함수 활용
  애니메이션: @keyframes + transition

Vue_패턴:
  API_스타일: Options API
  상태_관리: data() 반응형 객체
  파생_상태: computed 속성
  부수_효과: watch 감시자
  생명주기: mounted, beforeUnmount

JavaScript_스타일:
  ES6+: const/let, 화살표_함수, 템플릿_리터럴
  비동기: async/await (saveAsImage)
  DOM_조작: $refs, $nextTick
  반응성: this.속성 = 값
```

## 📋 문서 업데이트 규칙

```yaml
업데이트_필수:
  - 새_워크플로우_단계_추가
  - 새_Vue_메서드_추가
  - 주요_알고리즘_변경 (좌표_계산, 경로_파싱)
  - 아키텍처_변경 (상태_구조, 컴포넌트_설계)
  - 주요_버그_수정 (재현_방법, 원인, 해결책)

업데이트_불필요:
  - CSS_색상_변경
  - 텍스트_문구_수정
  - 포맷팅_변경
  - 마이너_리팩토링
```

## 🎮 UI 컴포넌트 상세 정보

```yaml
툴바_컨트롤:
  위치: .toolbar (lines 176-285)

  제목_표시:
    클래스: .toolbar__title
    내용: "MAINTENANCE WORKFLOW"
    스타일: 대문자, 0.08em 자간, 600 두께
    색상: --toolbar-title-color (테마별 다름)

  테마_전환_버튼:
    클래스: .toolbar__theme-button--light / --dark
    디자인: 원형 아이콘 버튼 (36x36px)
    아이콘:
      - 라이트: 태양 아이콘 (SVG)
      - 다크: 달 아이콘 (SVG)
    기능:
      - 클릭 시 theme 변수 변경 ("light" / "dark")
      - localStorage에 저장 (키: "maintenanceWorkflowTheme")
      - CSS 커스텀 속성 자동 전환
    시각_효과:
      - is-active 클래스: 활성 테마 강조
      - 펄스 애니메이션: ::after 가상 요소
      - 그라디언트 배경: linear-gradient
      - 호버: translateY(-1px), box-shadow 증가
    개선사항:
      - 텍스트 제거 ("라이트", "다크")
      - "테마" 라벨 제거
      - 더 컴팩트하고 직관적인 UI

  줌_컨트롤_버튼:
    디자인: 아이콘 전용 버튼 (toolbar__button--icon-only)
    크기: 36px, 아이콘 20x20px

    전체보기_버튼 (#zoomFit):
      - 기능: 자동 스케일 계산 (뷰포트에 맞춤)
      - aria-pressed: isFit 상태 반영
      - 동작: fitToView() 메서드 호출
      - 아이콘: 4개 선 + 사각형 + 모서리 화살촉 4개 (바깥쪽 방향)
      - 화살촉_위치: (3,3), (21,3), (3,21), (21,21) - 각 모서리
      - 툴팁: "전체 보기"

    축소_버튼 (#zoomOut):
      - 기능: scale - 0.1 (최소 0.1)
      - 비활성화: isFit=true 시
      - 아이콘: 마이너스 (-) 단순 아이콘
      - 툴팁: "축소"

    기본_크기_버튼 (#zoomReset):
      - 기능: scale = 1, isFit = false
      - 동작: resetZoom() 메서드 호출
      - 아이콘: 리셋 화살표
      - 툴팁: "기본 크기"

    확대_버튼 (#zoomIn):
      - 기능: scale + 0.1 (최대 2.0)
      - 단축키: 없음 (클릭만)
      - 아이콘: 플러스 (+) 단순 아이콘
      - 툴팁: "확대"

    개선사항:
      - 돋보기 제거, 직관적인 아이콘으로 변경
      - 툴팁 추가 (has-tooltip 클래스, data-tooltip 속성)
      - 줌 범위 조정 (30%~500% → 10%~200%)

    줌_슬라이더:
      - 클래스: .toolbar__zoom-slider
      - 구성: .zoom-slider-wrapper (마커 포함) + input[type="range"] + 퍼센트 라벨
      - 범위: 0.1 ~ 2.0 (10% ~ 200%)
      - 단계: 0.1
      - v-model: scale (양방향 바인딩)
      - 이벤트:
        - @input="onSliderChange" (슬라이더 값 변경)
        - @click="handleSliderMarkerClick" (마커 클릭)
      - 스타일:
        - 슬라이더 너비: 120px
        - 썸 크기: 16x16px (원형)
        - 호버 시: 1.2배 확대 + 파란색 그림자
      - 100%_마커:
        - 위치: 47.37% (0.9 / 1.9 * 100%)
        - 스타일: 2px 너비, 12px 높이, accent-strong 색상
        - 라벨: 제거됨 (세로선만 표시)
        - 클릭: ±10px 범위 내 클릭 시 scale = 1.0

  처음으로_버튼 (#resetButton):
    기능:
      - 워크플로우 완전 초기화 및 시작 화면 복귀
      - resetFlow() 메서드 호출
    디자인: 아이콘 전용 버튼 (toolbar__button--icon-only)
    위치: 이미지 저장 버튼 왼쪽
    비활성화: started=false 시
    아이콘: SVG 집 모양 (home icon)
    툴팁: "처음으로"
    동작:
      - 워크플로우 초기화
      - 디버그 레이어 자동 닫기
      - 진행도 리셋
      - 스크롤 및 줌 리셋

  공유_버튼 (#shareWorkflow):
    기능:
      - 워크플로우 공유 (이미지/텍스트)
      - Windows 공유 센터 우선 시도 (텍스트만)
      - 실패 시 커스텀 공유 센터 모달 표시
      - 탭 구분: 이미지 공유 / 텍스트 공유
    디자인: 아이콘 전용 버튼 (toolbar__button--icon-only)
    비활성화: started=false 시
    아이콘: Windows 스타일 공유 아이콘 (사각형 + 우상향 화살표)
    툴팁: "공유하기"
    동작: shareWorkflow() 메서드 호출
    공유_옵션:
      - 이미지_공유: PNG 다운로드 + 이메일 본문에 텍스트 다이어그램
      - 텍스트_공유: 클립보드 복사 + 빈 이메일 열기 (서명 위 붙여넣기)

  이미지_저장_버튼 (#saveImage):
    기능:
      - 워크플로우 캡처 → PNG 다운로드
      - html2canvas 라이브러리 사용
      - 파일명: workflow-{timestamp}.png
    디자인: 아이콘 전용 버튼 (toolbar__button--icon-only)
    비활성화: started=false 시
    아이콘: SVG 카메라
    툴팁: "PNG로 내보내기"
    동작: saveAsImage() 메서드 호출

  디버그_버튼 (#debugToggle):
    기능:
      - 디버그 레이어 표시/숨김 토글
      - toggleDebugLayer() 메서드 호출
    디자인: 아이콘 전용 버튼 (toolbar__button--icon-only)
    위치: 확대 버튼 우측 (toolbar__actions 그룹)
    아이콘: SVG 벌레 모양 (bug icon)
      - 머리: 타원 (cx="12" cy="7" rx="5" ry="4")
      - 몸통: 타원 (cx="12" cy="17" rx="7" ry="5.5")
      - 선: 세로선 + 가로선 3개 (세그먼트 표현)
      - 눈: 흰색 원 2개 (cx="9" cy="7", cx="15" cy="7")
    툴팁: "디버그 로그"
    상태_표시:
      - is-active 클래스: debugLayerVisible=true 시
      - 펄스 애니메이션: debugPulse (노란색 box-shadow)
      - 키프레임:
        - 0%, 100%: box-shadow 0 0 0 0 rgba(250, 204, 21, 0.4)
        - 50%: box-shadow 0 0 0 6px rgba(250, 204, 21, 0)
      - 애니메이션: 2s ease-in-out infinite

진행도_바:
  위치: 툴바 배경 (.toolbar::before 가상 요소)
  표시_조건: started=true 시 (has-progress 클래스)
  변경사항: 별도 섹션 제거, 툴바 배경으로 통합

  진행률_배경:
    구현: .toolbar.has-progress::before
    위치: absolute (left: 0, top: 0, bottom: 0)
    너비: calc(var(--progress-ratio, 0) * 100%)
    배경: linear-gradient(90deg,
           rgba(56, 189, 248, 0.25),    # 청색 (25% 투명도)
           rgba(244, 114, 182, 0.22),   # 분홍색 (22% 투명도)
           rgba(250, 204, 21, 0.2))     # 노란색 (20% 투명도)
    애니메이션: width 0.4s cubic-bezier(0.22, 1, 0.36, 1)
    z-index: 0 (툴바 버튼들은 z-index: 1)
    pointer-events: none

  진행률_계산:
    변수: --progress-ratio (0~1)
    값: progressRatio computed 속성
    공식: selectedCount / expectedMaxSteps
    안정성: maxExpectedSteps로 단조 증가 보장

  개선사항:
    - UI 간소화: 별도 진행도 바 섹션 제거
    - 공간 효율: 툴바를 진행도 표시로 활용
    - 시각적 통합: 배경 그라디언트로 자연스러운 표현

워크플로우_캔버스:
  뷰포트 (.workflow-viewport):
    역할: 스크롤_컨테이너 + 드래그_영역
    특성:
      - overflow: auto (스크롤바 표시)
      - cursor: grab (드래그 가능)
      - 드래그 시: cursor: grabbing
    이벤트:
      - @mousedown: handleDragStart() (드래그 시작)
      - @wheel: handleWheel() (휠 스크롤)
    크기: flex: 1 (남은 공간 채움)

  캔버스 (.workflow-canvas):
    역할: 스케일_변환_대상
    특성:
      - transform: scale({{ scale }})
      - transform-origin: top left
      - 스케일 범위: 0.3 ~ 1.5
    크기_계산:
      - 너비: visibleStages.length × 346px (명시적 설정)
      - 높이: 자동 (콘텐츠 기준)

  시작_화면 (.workflow-start):
    표시_조건: v-if="!started"
    구성:
      - 제목: "유지보수 워크플로우 시뮬레이션"
      - 설명: 기능 안내 텍스트
      - 시작_버튼: startFlow() 호출
    스타일:
      - 레이아웃: display: grid
      - 정렬: justify-items: center, align-content: center
      - flex: 1, min-height: 0 (세로 공간 채움)
      - 점선_테두리: dashed border
      - 패딩: clamp(2rem, 6vw, 3rem)
    개선사항:
      - 세로_공간_활용: flex: 1로 뷰포트 전체 높이 활용
      - 중앙_배치: align-content: center로 수직 중앙 정렬

  워크플로우_보드 (.workflow-board):
    표시_조건: v-if="started"
    역할: 단계_컨테이너
    특성:
      - display: flex
      - gap: var(--board-gap)
      - align-items: stretch

  단계_리스트_래퍼 (.workflow-stage-list):
    역할: SVG_연결선_레이어 + 단계_카드_컨테이너
    특성:
      - width: {{ visibleStages.length × 346 }}px (동적 설정)
      - min-width, max-width: 동일 (고정)
      - scroll-snap-type: x proximity
      - aria-live: polite (접근성)
    이벤트: v-for 루프로 단계 카드 렌더링

단계_카드 (.workflow-stage):
  크기:
    - width: var(--stage-width) (346px)
    - 패딩: clamp(0.75rem, 1.6vw, 1.05rem)
    - border-radius: var(--radius-lg) (24px)
  상태_클래스:
    - is-visible: opacity 1, translateY(0)
    - is-complete: 선택 완료 시 (노란색 테두리)
  애니메이션:
    - 초기: opacity 0, translateY(24px), scale(0.97)
    - 진입: 0.45s cubic-bezier(0.22, 1, 0.36, 1)
  구성:
    헤더 (.workflow-stage__header):
      - STEP 번호: {{ padStep(stage.id) }} (01, 02, ...)
      - 제목: {{ stage.title }}

    선택_표시 (.workflow-stage__choice):
      - 내용: {{ getSelectedLabel() || '선택을 진행하세요' }}
      - is-active: 선택 시 그라디언트 배경
      - 높이: var(--choice-height) (42px~56px)

    옵션_박스 (.workflow-stage__options-box):
      - 제목: "선택 대상"
      - 옵션_리스트: v-for로 렌더링
      - 배경: --options-bg

    옵션_버튼 (.workflow-option):
      - 크기: 높이 = choice-height × 0.5
      - 상태:
        - 기본: --option-bg
        - 호버: translateY(-1px), box-shadow
        - 선택: is-selected 클래스 (그라디언트 + 노란 테두리)
      - 이벤트: @click="handleSelection(index, item)"

SVG_연결선_레이어:
  컨테이너 (.workflow-connector-layer):
    역할: SVG_캔버스
    특성:
      - position: absolute, inset: 0
      - pointer-events: none (클릭 차단)
      - z-index: 99999 (최상위)
      - overflow: visible
    크기: {{ connectorSize.width }} × {{ connectorSize.height }}

  연결선 (.workflow-connector-line):
    스타일:
      - stroke: url(#connectorGradient) (그라디언트)
      - stroke-width: 4
      - stroke-dasharray: 6 4 (점선)
      - pathLength: 100 (일관된 애니메이션)
      - vector-effect: non-scaling-stroke
      - filter: drop-shadow (그림자)
    상태_클래스:
      - is-active: opacity 1 (표시)
      - has-flow: 흐름 애니메이션
      - animate-draw: 그리기 애니메이션
    애니메이션:
      - connectorDraw: 1.2s (한 번)
      - connectorFlow: 2s infinite (무한)

  연결점 (.workflow-connector-dot):
    역할: 시작점/끝점 표시
    크기: r="6" (반지름)
    색상: --accent-strong (#fcd34d)
    상태:
      - 기본: opacity 0, scale(0.6)
      - is-active: opacity 1, scale(1)
    애니메이션: 0.35s ease

디버그_레이어:
  컨테이너 (.workflow-debug-layer):
    표시_조건: v-if="debugLayerVisible"
    위치: fixed (우측 하단)
      - right: 1.2rem
      - bottom: 1.2rem
      - z-index: 999999
    크기:
      - width: clamp(380px, 28vw, 480px)
      - height: clamp(280px, 32vh, 400px)
    스타일:
      - 배경: --bg-card (카드 배경)
      - 테두리: 1px solid --border-color
      - 둥근_모서리: var(--radius-lg) (24px)
      - 그림자: 0 12px 48px rgba(0, 0, 0, 0.35)

  헤더 (.workflow-debug-layer__header):
    구성:
      - 제목: "디버그 로그" (h3)
      - 버튼_그룹: 복사, 초기화, 닫기
    스타일:
      - 패딩: 0.9rem 1.2rem
      - 테두리_하단: 1px solid --border-color
      - display: flex, justify-content: space-between

  액션_버튼 (.workflow-debug-layer__actions):
    버튼들:
      복사_버튼:
        - 텍스트: "복사"
        - 기능: copyDebugLogs() - 클립보드 복사
        - 클래스: .workflow-debug-layer__button

      초기화_버튼:
        - 텍스트: "초기화"
        - 기능: clearDebugLogs() - 로그 비우기
        - 클래스: .workflow-debug-layer__button

      닫기_버튼:
        - 아이콘: X (SVG)
        - 기능: toggleDebugLayer() - 레이어 닫기
        - 클래스: .workflow-debug-layer__close
        - 크기: 28x28px
        - 호버: 빨간색 (border-color: #ef4444)

    버튼_스타일:
      - 크기: 패딩 0.4rem 0.75rem
      - 폰트: 0.8rem
      - 테두리: 1px solid --toolbar-button-border
      - 배경: --toolbar-button-bg
      - 둥근_모서리: 6px
      - 호버: 배경 변경, box-shadow 추가

  로그_컨테이너 (.workflow-debug-layer__logs):
    역할: 스크롤 가능한 로그 리스트
    특성:
      - flex: 1 (남은 공간 채움)
      - overflow-y: auto
      - 패딩: 0.75rem
      - font-family: 'Consolas', monospace
    스크롤:
      - 자동_스크롤: $nextTick으로 최신 로그로 이동
      - scrollTop = scrollHeight

  로그_항목 (.workflow-debug-log):
    구조:
      - 시간: {{ log.time }} (회색)
      - 메시지: {{ log.message }}
    스타일:
      - 폰트: 0.75rem, monospace
      - 패딩: 0.3rem 0
      - 테두리_하단: 1px solid (반투명)
      - 시간_색상: --text-faded
      - 메시지_색상: --text-primary

  로그_형식:
    타임스탬프: YYYY-MM-DD HH:MM:SS.mmm
    예시:
      - "2025-10-04 14:23:45.123 테마 변경: 다크 모드"
      - "2025-10-04 14:24:10.456 단계 2 선택: 장애 (다음: 3)"
      - "2025-10-04 14:24:12.789 화살선 생성: line-1-to-2 (400,150 → 800,180)"

  로그_관리:
    - 최대_로그_수: 1000개
    - 제거_방식: FIFO (가장 오래된 로그 제거)
    - 복사_형식: "시간 메시지" (줄바꿈으로 구분)

인터랙션_특성:
  드래그_팬:
    활성_영역: .workflow-viewport
    제외_요소: button, select, a, input, textarea, .workflow-option
    동작:
      - 마우스_다운: dragState.active = true
      - 마우스_이동: viewport.scrollLeft/Top 조정
      - 마우스_업: dragState.active = false
    비활성_조건: isFit=true (전체보기 모드)

  휠_스크롤:
    기본: 상하_휠 → 좌우_스크롤 (scrollLeft += deltaY)
    Ctrl+휠: 빠른_좌우_스크롤 (scrollLeft += deltaY × 2)
    제외_요소: button, select, a, input, textarea, .workflow-option
    비활성_조건: isFit=true (이벤트 차단)

  키보드_네비게이션:
    포커스_자동_이동:
      - 시작 시: 첫 번째 옵션 포커스
      - 선택 시: 다음 단계 첫 번째 옵션 포커스
    조건: prefers-reduced-motion=false
    옵션: preventScroll: true (자동 스크롤 방지)
```

## 🚨 최종 체크리스트

```
✅ .commit_message.txt 수정
✅ git add . && git commit -F .commit_message.txt
✅ git push --force
✅ CLAUDE.md 업데이트 (중요_변경시)
✅ /compact 실행 (context 20% 이하시)
✅ ntfy 알림 전송 (절대_필수)
✅ 로그 삭제
✅ 완료
```
