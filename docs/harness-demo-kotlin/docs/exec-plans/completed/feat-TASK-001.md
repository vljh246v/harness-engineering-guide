# feat: Todo 완료 상태(completed) 필터 기능 추가 (TASK-001)

## 배경 및 목표

`GET /todos` API에 `done` 쿼리 파라미터를 추가하여, 완료/미완료 상태별로 Todo를 필터링할 수 있도록 한다.
- `GET /todos` → 전체 목록 (기존 동작 유지)
- `GET /todos?done=true` → 완료된 Todo만 반환
- `GET /todos?done=false` → 미완료 Todo만 반환

## 구현 단계

- [ ] 1. 영향 범위 파악 (관련 파일 확인) ✅
- [ ] 2. `TodoRepository`에 `findByDone(done: Boolean): List<Todo>` 메서드 추가
- [ ] 3. `TodoService`에 `getTodosByDone(done: Boolean): List<Todo>` 메서드 추가
- [ ] 4. `TodoController`의 `getAllTodos`에 `done: Boolean?` 쿼리 파라미터 추가
- [ ] 5. `TodoServiceTest`에 필터 관련 테스트 추가
- [ ] 6. 린트 확인
- [ ] 7. task-finish.sh 실행

## 영향 범위

| 레이어 | 파일 | 변경 내용 |
|--------|------|-----------|
| repository | `TodoRepository.kt` | `findByDone` 메서드 추가 |
| service | `TodoService.kt` | `getTodosByDone` 메서드 추가 |
| controller | `TodoController.kt` | `?done` 쿼리 파라미터 처리 |
| test | `TodoServiceTest.kt` | 필터 테스트 케이스 추가 |

## 완료 기준

- [ ] 검증기 5개 전부 통과
- [ ] 기존 테스트 통과
- [ ] `done=true` 필터 시 완료 항목만 반환
- [ ] `done=false` 필터 시 미완료 항목만 반환
- [ ] 파라미터 없을 때 전체 목록 반환 (하위 호환)

## 참고

- ARCHITECTURE.md
- logs/trends/failure-patterns.md
