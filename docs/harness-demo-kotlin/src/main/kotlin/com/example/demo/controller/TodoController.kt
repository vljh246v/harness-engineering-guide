package com.example.demo.controller

import com.example.demo.domain.Todo
import com.example.demo.service.TodoService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/todos")
class TodoController(
    private val todoService: TodoService,
) {
    @GetMapping
    fun getAllTodos(
        @RequestParam done: Boolean?,
    ): List<Todo> = if (done != null) todoService.getTodosByDone(done) else todoService.getAllTodos()

    @GetMapping("/{id}")
    fun getTodoById(
        @PathVariable id: Long,
    ): ResponseEntity<Todo> {
        val todo = todoService.getTodoById(id) ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(todo)
    }

    @PostMapping
    fun createTodo(
        @RequestBody request: CreateTodoRequest,
    ): ResponseEntity<Todo> {
        val todo = todoService.createTodo(request.title)
        return ResponseEntity.ok(todo)
    }

    @PatchMapping("/{id}/complete")
    fun completeTodo(
        @PathVariable id: Long,
    ): ResponseEntity<Todo> {
        val todo = todoService.completeTodo(id) ?: return ResponseEntity.notFound().build()
        return ResponseEntity.ok(todo)
    }

    @DeleteMapping("/{id}")
    fun deleteTodo(
        @PathVariable id: Long,
    ): ResponseEntity<Void> {
        if (!todoService.deleteTodo(id)) return ResponseEntity.notFound().build()
        return ResponseEntity.noContent().build()
    }

    data class CreateTodoRequest(
        val title: String,
    )
}
