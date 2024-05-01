<div>

[**简体中文**](README_zh_CN.md)

</div>

## FlClash

A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.

on Desktop:
<p style="text-align: center;">
    <img alt="desktop" src="snapshots/desktop.gif">
</p>

on Mobile:
<p style="text-align: center;">
    <img alt="mobile" src="snapshots/mobile.gif">
</p>

## Features

✈️ Multi-platform: Android, Windows, macOS and Linux

💻 Adaptive multiple screen sizes, Multiple color themes available

💡 Based on Material You Design, [Surfboard](https://github.com/getsurfboard/surfboard)-like UI

✨ Support subscription link, Dark mode

## Contact

[Telegram](https://t.me/+G-veVtwBOl4wODc1)

## Build

1. Update submodules
   ```bash
   git submodule update --init --recursive
   ```

2. Install `Flutter` and `Golang` environment

3. Build Application

    - android

        1. Install  `Android SDK` ,  `Android NDK`

        2. Set `ANDROID_NDK` environment variables

        3. Run Build script

           ```bash
           dart .\setup.dart android
           ```

    - windows

        1. You need a windows client

        2. Install  `Gcc`，`Inno Setup`

        3. Run build script

           ```bash
           dart .\setup.dart	
           ```

    - linux

        1. You need a linux client

        2. Run build script

           ```bash
           dart .\setup.dart	
           ```

    - macOS

        1. You need a macOS client

        2. Run build script

           ```bash
           dart .\setup.dart	
           ```
           

    