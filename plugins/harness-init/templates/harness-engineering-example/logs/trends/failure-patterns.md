# failure-patterns.md — Failure Pattern Analysis

Periodically updated by the GC agent from `logs/validators/history.jsonl`.
**Read this file before starting new work to learn from past failures.**

Last analyzed: (updated by GC agent)
Analysis period: last 30 days
Total tasks: 0 / Passed: 0 / Failed: 0

---

## Frequently Failing Validators

(The GC agent will update the table below as data accumulates)

| Validator | Failure Rate | Primary Cause | Prevention |
|-----------|-------------|---------------|------------|
| - | - | - | - |

---

## Recurring Error Patterns

(Added by the GC agent after analysis)

---

## Recommended Improvements

(Harness improvements suggested by the GC agent)

---

## Example Analysis Queries

```bash
# List all failures
cat logs/validators/history.jsonl | python3 -c "
import sys, json
failures = [json.loads(l) for l in sys.stdin if '\"fail\"' in l]
for f in failures[-10:]:
  print(f'{f[\"ts\"]} | {f[\"task\"]} | {f[\"validator\"]} | {f.get(\"error\",\"\")[:80]}')
"

# Failure rate per validator
cat logs/validators/history.jsonl | python3 -c "
import sys, json
from collections import Counter
data = [json.loads(l) for l in sys.stdin]
total = Counter(d['validator'] for d in data)
fails = Counter(d['validator'] for d in data if d['result']=='fail')
for v in sorted(total):
  rate = fails[v]/total[v]*100 if total[v] else 0
  print(f'{v}: {fails[v]}/{total[v]} ({rate:.0f}% failure)')
"
```
