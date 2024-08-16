<div>

[**English**](README.md) | [**简体中文**](README_zh_CN.md)

</div>

## FlClash

<p style="text-align: left;">
    <img alt="stars" src="https://img.shields.io/github/stars/chen08209/FlClash?style=flat-square&logo=github"/>
    <img alt="downloads" src="https://img.shields.io/github/downloads/chen08209/FlClash/total"/>
    <a href="LICENSE">
        <img alt="license" src="https://img.shields.io/github/license/chen08209/FlClash"/>
    </a>
</p>

ClashMetaに基づくマルチプラットフォームプロキシクライアントで、シンプルで使いやすく、オープンソースで広告なし。

デスクトップで:
<p style="text-align: center;">
    <img alt="desktop" src="snapshots/desktop.gif">
</p>

モバイルで:
<p style="text-align: center;">
    <img alt="mobile" src="snapshots/mobile.gif">
</p>

## 特徴

✈️ マルチプラットフォーム: Android, Windows, macOS, Linux

💻 複数の画面サイズに対応、複数のカラーテーマが利用可能

💡 基本的なMaterial Youデザイン、[Surfboard](https://github.com/getsurfboard/surfboard)のようなUI

☁️ WebDAVを介したデータ同期をサポート

✨ サブスクリプションリンク、ダークモードをサポート

## ダウンロード

<a href="https://chen08209.github.io/FlClash-fdroid-repo/repo?fingerprint=789D6D32668712EF7672F9E58DEEB15FBD6DCEEC5AE7A4371EA72F2AAE8A12FD"><img alt="Get it on F-Droid" src="snapshots/get-it-on-fdroid.svg" width="200px"/></a> <a href="https://github.com/chen08209/FlClash/releases"><img alt="Get it on GitHub" src="snapshots/get-it-on-github.svg" width="200px"/></a>

## 連絡先

[Telegram](https://t.me/+G-veVtwBOl4wODc1)

## ビルド

1. サブモジュールを更新
   ```bash
   git submodule update --init --recursive
   ```

2. `Flutter`と`Golang`環境をインストール

3. アプリケーションをビルド

    - android

        1. `Android SDK`と`Android NDK`をインストール

        2. `ANDROID_NDK`環境変数を設定

        3. ビルドスクリプトを実行

           ```bash
           dart .\setup.dart android
           ```

    - windows

        1. Windowsクライアントが必要

        2. `Gcc`と`Inno Setup`をインストール

        3. ビルドスクリプトを実行

           ```bash
           dart .\setup.dart	
           ```

    - linux

        1. Linuxクライアントが必要

        2. ビルドスクリプトを実行

           ```bash
           dart .\setup.dart	
           ```

    - macOS

        1. macOSクライアントが必要

        2. ビルドスクリプトを実行

           ```bash
             dart .\setup.dart	
           ```

## スター

開発者をサポートする最も簡単な方法は、ページの上部にある星（⭐）をクリックすることです。

<p style="text-align: center;">
    <a href="https://api.star-history.com/svg?repos=chen08209/FlClash&Date">
        <img alt="start" width=50% src="https://api.star-history.com/svg?repos=chen08209/FlClash&Date"/>
    </a>
</p>
