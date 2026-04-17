---
name: test-generation
description: TDD 방식으로 테스트를 작성할 때 사용하는 스킬
type: testing
---

# 테스트 생성 스킬

이 스킬은 새 기능 구현 전 테스트 먼저 작성(TDD) 또는 기존 코드 테스트 보강 시 사용합니다.

## TDD 플로우

```
1. RED   — 실패하는 테스트 먼저 작성
2. GREEN — 테스트를 통과하는 최소 구현
3. REFACTOR — 중복 제거, 구조 개선
```

## 테스트 작성 원칙

### 테스트명 규칙
```
// Kotlin
@Test
fun `should return error when user not found`() { }

// Python
def test_should_return_error_when_user_not_found(): pass

// TypeScript
it('should return error when user not found', () => {})
```

테스트명 형식: `should [결과] when [조건]`

### AAA 패턴
```kotlin
@Test
fun `should calculate total price including tax`() {
  // Arrange (준비)
  val item = Item(price = 1000, quantity = 2)

  // Act (실행)
  val result = PriceCalculator.calculate(item, taxRate = 0.1)

  // Assert (검증)
  assertEquals(2200, result.totalPrice)
}
```

## 테스트 체크리스트

### 기본
- [ ] Happy Path (정상 케이스) 커버
- [ ] Error Path (오류 케이스) 커버
- [ ] Edge Case (경계값) 커버

### 엣지 케이스 목록
- null / empty / blank 입력
- 최솟값 / 최댓값 (Int.MIN_VALUE 등)
- 빈 리스트 / 단일 항목 / 대량 항목
- 타임아웃 / 네트워크 오류
- 권한 없는 사용자

### 테스트 격리
- [ ] 각 테스트는 독립적으로 실행 가능한가?
- [ ] 테스트 간 공유 상태가 없는가?
- [ ] 외부 의존성(DB, API)은 Mock/Stub으로 대체했는가?

## 언어별 테스트 패턴

### Kotlin/Spring Boot
```kotlin
@SpringBootTest
@Transactional
class UserServiceTest {
  @Autowired lateinit var userService: UserService
  @MockBean lateinit var userRepository: UserRepository

  @Test
  fun `should find user by id`() {
    val user = User(id = 1L, name = "테스트")
    given(userRepository.findById(1L)).willReturn(Optional.of(user))

    val result = userService.findById(1L)

    assertNotNull(result)
    assertEquals("테스트", result.name)
  }
}
```

### TypeScript
```typescript
describe('UserService', () => {
  let service: UserService;
  let mockRepo: jest.Mocked<UserRepository>;

  beforeEach(() => {
    mockRepo = { findById: jest.fn() } as any;
    service = new UserService(mockRepo);
  });

  it('should find user by id', async () => {
    mockRepo.findById.mockResolvedValue({ id: 1, name: '테스트' });
    const result = await service.findById(1);
    expect(result.name).toBe('테스트');
  });
});
```

## 실패 패턴 참고

작업 전에 `logs/trends/failure-patterns.md`를 확인하여
자주 실패하는 테스트 패턴을 파악하세요.
