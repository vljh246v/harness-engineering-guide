# failure-patterns.md — 실패 패턴 분석

GC 에이전트가 `logs/validators/history.jsonl`을 분석하여 주기적으로 업데이트합니다.
**새 작업 시작 전에 이 파일을 읽어 과거 실패를 미리 파악하세요.**

마지막 분석: (GC 에이전트가 업데이트)
분석 기간: 최근 30일
총 태스크: 0 / 성공: 0 / 실패: 0

---

## 자주 실패하는 검증기

(데이터가 쌓이면 GC 에이전트가 아래 테이블을 업데이트합니다)

| 검증기 | 실패율 | 주요 원인 | 예방 방법 |
|--------|--------|-----------|-----------|
| - | - | - | - |

---

## 반복 오류 패턴

(GC 에이전트가 분석하여 추가합니다)

---

## 추천 개선사항

(GC 에이전트가 제안하는 하네스 개선 사항)

---

## 분석 쿼리 예시

```bash
# 모든 실패 이력 조회
cat logs/validators/history.jsonl | python3 -c "
import sys, json
failures = [json.loads(l) for l in sys.stdin if '\"fail\"' in l]
for f in failures[-10:]:
  print(f'{f[\"ts\"]} | {f[\"task\"]} | {f[\"validator\"]} | {f.get(\"error\",\"\")[:80]}')
"

# 검증기별 실패율
cat logs/validators/history.jsonl | python3 -c "
import sys, json
from collections import Counter
data = [json.loads(l) for l in sys.stdin]
total = Counter(d['validator'] for d in data)
fails = Counter(d['validator'] for d in data if d['result']=='fail')
for v in sorted(total):
  rate = fails[v]/total[v]*100 if total[v] else 0
  print(f'{v}: {fails[v]}/{total[v]} ({rate:.0f}% 실패)')
"
```
