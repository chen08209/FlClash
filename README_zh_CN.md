<div>

[**English**](README.md)

</div>

## FlClashPlus

[![Downloads](https://img.shields.io/github/downloads/nekobyran/flclashplus/total?style=flat-square&logo=github)](https://github.com/nekobyran/flclashplus/releases/)[![Last Version](https://img.shields.io/github/release/nekobyran/flclashplus/all.svg?style=flat-square)](https://github.com/nekobyran/flclashplus/releases/)[![License](https://img.shields.io/github/license/nekobyran/flclashplus?style=flat-square)](LICENSE)

FlClashPlus 是基于上游 [FlClash](https://github.com/chen08209/FlClash) 的修改发行版，不代表上游官方版本；归属信息见 [NOTICE.md](NOTICE.md)。

基于 ClashMeta 的多平台代理客户端，简单易用，开源无广告。项目采用 GNU GPL v3.0，允许商用，但须遵守 GPL 的源码公开、许可证保留和修改声明等条件。

on Desktop:
<p style="text-align: center;">
    <img alt="desktop" src="snapshots/desktop.gif">
</p>

on Mobile:
<p style="text-align: center;">
    <img alt="mobile" src="snapshots/mobile.gif">
</p>

## Features

✈️ 多平台: Android, Windows, macOS and Linux

💻 自适应多个屏幕尺寸,多种颜色主题可供选择

💡 基本 Material You 设计, 类[Surfboard](https://github.com/getsurfboard/surfboard)用户界面

☁️ 支持通过WebDAV同步数据

✨ 支持一键导入订阅, 深色模式

## Use

### Linux

⚠️ 使用前请确保安装以下依赖

   ```bash
    sudo apt-get install libayatana-appindicator3-dev
    sudo apt-get install libkeybinder-3.0-dev
   ```

### Android

支持下列操作

   ```bash
    com.follow.clash.action.START

    com.follow.clash.action.STOP

    com.follow.clash.action.TOGGLE
   ```

## Download

项目下载：[flclashplus.nkbr.cc](https://flclashplus.nkbr.cc/) · [GitHub Releases](https://github.com/nekobyran/flclashplus/releases)

### Homebrew

```bash
brew tap chen08209/tap
brew install --cask flclash
```

## Build

1. 更新 submodules
   ```bash
   git submodule update --init --recursive
   ```

2. 安装 `Flutter` 以及 `Golang` 环境

3. 构建应用

    - android

        1. 安装  `Android SDK` ,  `Android NDK`

        2. 设置 `ANDROID_NDK` 环境变量

        3. 运行构建脚本

           ```bash
           dart setup.dart android
           ```

    - windows

        1. 你需要一个windows客户端

        2. 安装 `GCC`，`Inno Setup`

        3. 运行构建脚本

           ```bash
           dart setup.dart windows
           ```

    - linux

        1. 你需要一个linux客户端

        2. 依赖会由 setup 脚本自动安装，也可以手动安装：
           ```bash
           sudo apt-get install -y libayatana-appindicator3-dev libkeybinder-3.0-dev
           ```

        3. 运行构建脚本

           ```bash
           dart setup.dart linux
           ```

    - macOS

        1. 你需要一个macOS客户端

        2. 运行构建脚本

           ```bash
           dart setup.dart macos
           ```

## Star

支持开发者的最简单方式是点击页面顶部的星标（⭐）。

<p style="text-align: center;">
    <a href="https://api.star-history.com/svg?repos=nekobyran/flclashplus&Date">
        <img alt="start" width=50% src="https://api.star-history.com/svg?repos=nekobyran/flclashplus&Date"/>
    </a>
</p>
