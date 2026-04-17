package com.example.demo.repository

import com.example.demo.domain.Todo
import org.springframework.stereotype.Repository
import java.util.concurrent.atomic.AtomicLong

@Repository
class TodoRepository {
    private val store = mutableMapOf<Long, Todo>()
    private val idGen = AtomicLong(1)

    fun findAll(): List<Todo> = store.values.toList()

    fun findByDone(done: Boolean): List<Todo> = store.values.filter { it.done == done }

    fun findById(id: Long): Todo? = store[id]

    fun save(title: String): Todo {
        val id = idGen.getAndIncrement()
        val todo = Todo(id = id, title = title)
        store[id] = todo
        return todo
    }

    fun update(todo: Todo): Todo? {
        if (!store.containsKey(todo.id)) return null
        store[todo.id] = todo
        return todo
    }

    fun delete(id: Long): Boolean = store.remove(id) != null
}
