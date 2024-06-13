package com.follow.clash.models

data class Process(
    val id: Int,
    val metadata: Metadata,
)

data class Metadata(
    val network: String,
    val sourceIP: String,
    val sourcePort: Int,
    val destinationIP: String,
    val destinationPort: Int,
    val host: String
)
