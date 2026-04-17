---
name: debugging
description: 버그나 테스트 실패를 체계적으로 추적하고 수정할 때 사용
type: debugging
---

# 디버깅 스킬

버그, 테스트 실패, 예상치 못한 동작 발생 시 사용합니다.

## 체계적 디버깅 플로우

```
1. 재현 — 버그를 일관되게 재현하는 최소 케이스 찾기
2. 격리 — 문제 범위를 좁히기
3. 가설 — 원인 가설 세우기
4. 검증 — 가설을 테스트로 검증
5. 수정 — 루트 원인 수정 (증상이 아닌)
6. 확인 — 수정 후 재현 케이스로 확인
```

## 디버깅 시작 전 확인

```bash
# 세션 로그에서 실패 이전 이벤트 확인
cat logs/sessions/<task-name>/session.jsonl | python3 -m json.tool | grep "error\|fail"

# 최근 검증기 실패 패턴 확인
cat logs/trends/failure-patterns.md

# 검증기 이력에서 유사 실패 찾기
cat logs/validators/history.jsonl | python3 -c "
import sys, json
for line in sys.stdin:
  d = json.loads(line)
  if d.get('result') == 'fail':
    print(d)
"
```

## 원인 분류

### 컴파일/빌드 오류
- 타입 불일치, 미선언 변수 → 해당 파일 라인 직접 수정
- 의존성 누락 → build 파일 확인
- 레이어 위반 → ARCHITECTURE.md 참고

### 런타임 오류
- NullPointerException → null 입력 케이스 추가, Optional 사용
- ClassCastException → 타입 확인 로직 추가
- StackOverflow → 재귀 종료 조건 확인

### 테스트 실패
- Assertion 실패 → 기대값 vs 실제값 비교
- Setup 문제 → @BeforeEach, fixture 확인
- 타이밍 문제 → async/await, sleep 제거

## 로그 분석 패턴

```bash
# 특정 에러 패턴 검색
grep -r "ERROR\|Exception\|FAIL" logs/sessions/ | tail -20

# 특정 파일 변경과 실패 상관관계
cat logs/sessions/<task>/session.jsonl | python3 -c "
import sys, json
events = [json.loads(l) for l in sys.stdin]
for i, e in enumerate(events):
  if e.get('event') == 'validator' and e.get('result') == 'fail':
    # 실패 전 5개 이벤트 출력
    for prev in events[max(0,i-5):i]:
      print('BEFORE:', prev)
    print('FAIL:', e)
"
```

## 절대 하지 말 것

- 증상만 숨기기 (try-catch로 예외 삼키기)
- 하드코딩으로 특정 케이스만 통과시키기
- 테스트를 실패 케이스에 맞게 수정하기 (구현을 수정해야 함)
- `// TODO: fix later` 남기고 넘어가기

## 수정 후 체크리스트

- [ ] 재현 케이스에서 수정 확인
- [ ] 관련 유사 케이스도 확인 (같은 버그가 다른 곳에도?)
- [ ] 테스트 추가 (이 버그의 재발 방지)
- [ ] session.jsonl에 수정 내용 자동 기록됨
