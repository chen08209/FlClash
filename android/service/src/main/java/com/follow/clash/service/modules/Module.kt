package com.follow.clash.service.modules

abstract class Module {

    var isInstall: Boolean = false

    protected abstract fun onInstall()
    protected abstract fun onUninstall()

    fun install(){
        isInstall = true
        onInstall()
    }

    fun uninstall(){
        onUninstall()
        isInstall = false
    }
}