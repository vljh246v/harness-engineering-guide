package com.example.demo.domain

data class Todo(
    val id: Long,
    val title: String,
    val done: Boolean = false,
)
