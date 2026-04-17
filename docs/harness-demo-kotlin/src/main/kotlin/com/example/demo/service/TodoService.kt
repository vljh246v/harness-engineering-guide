package com.example.demo.service

import com.example.demo.domain.Todo
import com.example.demo.repository.TodoRepository
import org.springframework.stereotype.Service

@Service
class TodoService(
    private val todoRepository: TodoRepository,
) {
    fun getAllTodos(): List<Todo> = todoRepository.findAll()

    fun getTodosByDone(done: Boolean): List<Todo> = todoRepository.findByDone(done)

    fun getTodoById(id: Long): Todo? = todoRepository.findById(id)

    fun createTodo(title: String): Todo {
        require(title.isNotBlank()) { "제목은 비워둘 수 없습니다" }
        return todoRepository.save(title)
    }

    fun completeTodo(id: Long): Todo? {
        val todo = todoRepository.findById(id) ?: return null
        return todoRepository.update(todo.copy(done = true))
    }

    fun deleteTodo(id: Long): Boolean = todoRepository.delete(id)
}
