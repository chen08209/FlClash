package com.follow.clash.models

import java.util.Date

data class Package(
    val packageName: String,
    val label: String,
    val isSystem: Boolean,
    val firstInstallTime: Long,
)
