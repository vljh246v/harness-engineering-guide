package com.example.demo.service

import com.example.demo.repository.TodoRepository
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows

class TodoServiceTest {
    private val repository = TodoRepository()
    private val service = TodoService(repository)

    @Test
    fun `createTodo - 제목과 함께 Todo가 생성된다`() {
        val todo = service.createTodo("장보기")
        assertEquals("장보기", todo.title)
        assertFalse(todo.done)
    }

    @Test
    fun `createTodo - 빈 제목이면 예외가 발생한다`() {
        assertThrows<IllegalArgumentException> {
            service.createTodo("   ")
        }
    }

    @Test
    fun `completeTodo - 존재하는 Todo를 완료 처리한다`() {
        val created = service.createTodo("책 읽기")
        val completed = service.completeTodo(created.id)
        assertNotNull(completed)
        assertTrue(completed!!.done)
    }

    @Test
    fun `completeTodo - 존재하지 않는 id면 null을 반환한다`() {
        val result = service.completeTodo(999L)
        assertNull(result)
    }

    @Test
    fun `deleteTodo - 존재하는 Todo를 삭제한다`() {
        val created = service.createTodo("삭제 대상")
        assertTrue(service.deleteTodo(created.id))
        assertNull(service.getTodoById(created.id))
    }

    @Test
    fun `getAllTodos - 전체 목록을 반환한다`() {
        service.createTodo("항목 1")
        service.createTodo("항목 2")
        assertEquals(2, service.getAllTodos().size)
    }

    @Test
    fun `getTodosByDone - done=true이면 완료된 항목만 반환한다`() {
        val t1 = service.createTodo("완료 항목")
        service.createTodo("미완료 항목")
        service.completeTodo(t1.id)
        val result = service.getTodosByDone(true)
        assertEquals(1, result.size)
        assertTrue(result.all { it.done })
    }

    @Test
    fun `getTodosByDone - done=false이면 미완료 항목만 반환한다`() {
        val t1 = service.createTodo("완료될 항목")
        service.createTodo("미완료 항목")
        service.completeTodo(t1.id)
        val result = service.getTodosByDone(false)
        assertEquals(1, result.size)
        assertTrue(result.all { !it.done })
    }

    @Test
    fun `getTodosByDone - 해당 상태 항목이 없으면 빈 목록을 반환한다`() {
        service.createTodo("미완료 항목")
        val result = service.getTodosByDone(true)
        assertTrue(result.isEmpty())
    }
}
