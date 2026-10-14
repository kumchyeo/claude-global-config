---
name: robot-eval-campaign
description: 실물 로봇 policy(VLA/IL/RL ckpt) 평가 캠페인 실행과 승격 판정. "평가 돌려", "ckpt 비교", "성공률 측정", "eval campaign" 요청 시 사용
---
## 목적
새 ckpt를 조건 매트릭스로 N회 실행하고 Wilson CI 하한으로 기준 ckpt 대비 승격 여부를 판정한다.

## 언제 쓰는지
"새 ckpt 평가 돌려줘", "A랑 B ckpt 비교", "조건별 성공률 측정"

## 입력
- 평가 ckpt 경로, 기준 ckpt 경로
- files/eval_matrix.yaml (조건: pose bin × 조명 × 개체 ID, N)
- 프로젝트 CLAUDE.md의 평가·검증 명령

## 순서
1. files/preflight.sh — safety config 해시 확인, 카메라 연결, reset 가능 상태 확인. 실패 시 중단.
2. 캠페인 실행 (bounded tool: run_episode / reset / get_logs 만 사용). 짝 작업을 reset으로 사용.
3. 에피소드마다 files/verify_*.py (L0 센서 + L1 기하) → results.jsonl 한 행 (episode_id, ckpt_hash, cond, pass, evidence)
4. 5% 무작위 샘플을 사람 audit 큐에 넣는다 (files/audit_queue.md).
5. files/analyze.py — 조건별 성공률·Wilson CI 하한, 실패 클러스터(failure_taxonomy.md 라벨).
6. 기준 ckpt 대비 비교표. 승격 조건 충족 여부 한 줄.

## 결정
- preflight 실패 → 실행하지 않는다.
- reset 연속 3회 실패 → 중단, 사용자 호출.
- audit FP rate > 5% → 캠페인 결과 무효, verifier 수정이 먼저.
- L2 classifier와 L1 불일치 → L1 우선.
- 승격 = 고정 real eval set에서 CI 하한이 기준 ckpt 성공률 점추정을 넘을 때. 아니면 보류.

## 완료의 정의 (실패할 수 있는 검증)
- results.jsonl 행 수 == Σ(조건 × N)
- 리포트의 모든 성공률이 results.jsonl에서 재계산 시 일치
- 모든 수치에 episode_id 추적 가능
- 실패 에피소드 전부 failure_taxonomy.md 라벨 보유
- audit_queue.md 샘플 수 ≥ 전체의 5%
- safety_limits 해시가 preflight 기록과 동일 (변경 없음)
- 비교표에 기준 ckpt·평가 ckpt hash 명시

## 예외 사례
- notes.md 참조
