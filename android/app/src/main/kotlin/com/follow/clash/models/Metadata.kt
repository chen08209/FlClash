package com.follow.clash.models

data class Metadata(
    val network: String,
    val sourceIP: String,
    val sourcePort: Int,
    val destinationIP: String,
    val destinationPort: Int,
    val remoteDestination: String,
    val host: String
)
