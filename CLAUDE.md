# CLAUDE.md - 워크플로우 시뮬레이션 프로젝트 매뉴얼

이 문서는 Claude Code가 Workflow 프로젝트에서 작업할 때 필요한 모든 정보를 포함합니다.

## ⚠️ 필수 작업 순서

```yaml
강제_작업_절차:
  1_커밋_준비:
    파일: .commit_message.txt
    형식: "[클로드] {이모지} {설명} (claude-sonnet-4-5-20250929)"
    인코딩: UTF-8
    순서:
      - Read .commit_message.txt
      - Edit .commit_message.txt (기존 내용 덮어쓰기)

  2_git_작업:
    명령어:
      - git add .
      - git commit -F .commit_message.txt
      - git push --force

  3_ntfy_알림:
    필수: 절대_필수_절대_빠뜨리지_말것
    실행_시점: 모든_작업_완료_직전
    명령어: |
      echo '{
        "topic": "MarsAlert",
        "title": "클로드코드 작업 완료",
        "message": "작업 요약: [구체적인_작업_내용]\n\n커밋 내역:\n- [커밋들]",
        "priority": 4,
        "tags": ["checkmark", "AI", "Claude", "complete"]
      }' > temp_claude_final.json
      curl https://ntfy.sh -H "Content-Type: application/json; charset=utf-8" --data-binary @temp_claude_final.json
      rm temp_claude_final.json

  4_문서_업데이트:
    조건: 중요한_변경_발생시
    대상: CLAUDE.md
    변경사항:
      - 새_파일_생성
      - 새_함수_추가
      - 주요_로직_변경
      - 아키텍처_변경
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
    역할: 현재 경로의 예상 최대 단계 수 동적 계산
    반환값: Number (최소 5 ~ 최대 9)
    동작:
      - visibleStages가 비어있으면 → 9 (전체 단계)
      - 마지막 단계가 9(완료)면 → visibleStages.length
      - 그 외 → 마지막 선택의 nextSteps 파싱 후 남은 최대 거리 계산
    호출: progressRatio에서 사용

  - 속성명: calculateMaxDistanceToCompletion(stageId)
    역할: 주어진 단계에서 완료까지의 최대 거리
    반환값: Number (1~5)
    매핑:
      - 1단계 → 5 (1→2→4→5.1→9)
      - 2단계 → 4 (2→4→5.1→9)
      - 5단계 → 5 (5→6→7→8→9 최장 경로)
      - 9단계 → 1 (완료)

  - 속성명: progressRatio
    역할: 진행률 계산 (0~1)
    변경: selectedCount / workflowSteps.length → selectedCount / expectedMaxSteps
    효과: 경로별 정확한 진행률 표시 (완료 시 항상 100%)

핵심_함수:
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
      - addNextStages()로 다음 단계 추가
      - 캔버스 크기 업데이트 (visibleStages × 346px)
      - updateConnections(false) 호출
      - resetZoom() + scrollToRight()
    호출빈도: 매_선택마다 (사용자_인터랙션)

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
    호출빈도: 이미지_저장_버튼_클릭_시
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
    단계_너비: 356px (카드 346px + 여유 10px)
    캔버스_너비: visibleStages.length × 356px
```

## 🎯 중요 구현 세부사항

```yaml
단계_너비_계산:
  고정_너비: 356px (단계 346px + 여유 10px)
  총_캔버스_너비: visibleStages.length × 356px
  명시적_설정_위치:
    - handleSelection() line 1313: const stageWidth = 356
    - updateConnections() line 1431: const stageWidth = 356
    - updateConnections() line 1442: calculatedWidth = stageCount * 356
    - updateConnections() line 1549: calculatedWidth = stageCount * 356

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
git push --force
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
    - handleSelection() line 1313: const stageWidth = 356
    - updateConnections() line 1431: const stageWidth = 356
    - updateConnections() line 1442: calculatedWidth = stageCount * 356
    - updateConnections() line 1549: calculatedWidth = stageCount * 356
    - 주의: 모든_위치_동시_변경_필수 (현재 356px = 단계 346px + 여유 10px)

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
    기능:
      - 클릭 시 theme 변수 변경 ("light" / "dark")
      - localStorage에 저장 (키: "maintenanceWorkflowTheme")
      - CSS 커스텀 속성 자동 전환
    시각_효과:
      - is-active 클래스: 활성 테마 강조
      - 펄스 애니메이션: ::after 가상 요소 (lines 265-274)
      - 그라디언트 배경: linear-gradient
      - 호버: translateY(-1px), box-shadow 증가

  줌_컨트롤_버튼:
    확대_버튼 (#zoomIn):
      - 기능: scale + 0.1 (최대 1.5)
      - 단축키: 없음 (클릭만)
      - 아이콘: SVG 플러스 (+)

    축소_버튼 (#zoomOut):
      - 기능: scale - 0.1 (최소 0.3)
      - 비활성화: isFit=true 시
      - 아이콘: SVG 마이너스 (-)

    기본_크기_버튼 (#zoomReset):
      - 기능: scale = 1, isFit = false
      - 동작: resetZoom() 메서드 호출
      - 아이콘: SVG 십자 (리셋)

    전체보기_버튼 (#zoomFit):
      - 기능: 자동 스케일 계산 (뷰포트에 맞춤)
      - aria-pressed: isFit 상태 반영
      - 동작: fitToView() 메서드 호출
      - 아이콘: SVG 확대경

    줌_퍼센트_표시:
      - 클래스: .toolbar__scale
      - 내용: {{ zoomPercent }}% (계산된 속성)
      - 스타일: 최소 72px 너비, 중앙 정렬
      - 읽기_전용: 버튼 아님

  이미지_저장_버튼 (#saveImage):
    기능:
      - 워크플로우 캡처 → PNG 다운로드
      - html2canvas 라이브러리 사용
      - 파일명: workflow-{timestamp}.png
    비활성화: started=false 시
    아이콘: SVG 카메라
    동작: saveAsImage() 메서드 호출

진행도_바:
  위치: .workflow-progress (lines 399-463)
  표시_조건: v-if="started" (시작 후에만 표시)

  진행률_트랙:
    클래스: .workflow-progress__track
    역할: progressbar (ARIA)
    속성:
      - aria-valuemin: 0
      - aria-valuemax: workflowSteps.length (9)
      - aria-valuenow: selectedCount (현재 선택 수)

  진행률_바:
    클래스: .workflow-progress__bar
    스타일: transform: scaleX({{ progressRatio }})
    배경: linear-gradient (청색→보라→분홍→노랑)
    애니메이션: cubic-bezier(0.22, 1, 0.36, 1) 0.4s

  메타_정보:
    선택_수_라벨:
      - 내용: "{{ selectedCount }} 단계 선택 ({{ visibleStages.length }} 단계 표시 중)"
      - 스타일: 0.85rem, --text-secondary 색상

    디버그_정보 (debugEnabled=true):
      - 표시: 단계박스 개수, 계산크기, 뷰포트, 캔버스, 보드, 스테이지리스트 width
      - 위치: 진행도 바 우측
      - 스타일: 0.78rem, --text-faded 색상

  리셋_버튼:
    클래스: .workflow-reset
    기능: resetFlow() 메서드 호출
    비활성화: started=false 시
    동작:
      - started = false
      - selections, visibleStages, lines 초기화
      - scale = 1, 스크롤 (0,0)
    스타일: 999px 테두리 반경 (둥근 버튼)

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
      - 중앙_정렬: justify-items: center
      - 점선_테두리: dashed border
      - 패딩: clamp(2rem, 6vw, 3rem)

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
✅ ntfy 알림 전송 (절대_필수)
✅ CLAUDE.md 업데이트 (중요_변경시)
✅ 완료
```
