package com.follow.clash

/**
 * Holds external requests that arrived while no Flutter engine was alive
 * (e.g. a Modes-and-Routines shortcut fired after the app was swiped away).
 * MainActivity drains them once Dart is up and applies each through the
 * normal in-app path, so a request is never silently lost.
 */
object ModeRequest {
    @Volatile
    var pending: String? = null

    @Volatile
    var pendingProfileId: Long? = null
}
