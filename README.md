## FlClash0.8.97 Prebuilt Packages for Ubuntu 20.04

Prebuilt Linux packages compatible with **Ubuntu 20.04 / glibc 2.31** are available from OneDrive.

- `.deb`
- `.rpm`
- `.AppImage`

[Download from OneDrive](https://1drv.ms/f/c/04017f21f5709366/IgByTu3WxfnmS56qz1en6QipAT8nROoc2t4dD1qhXC04B08?e=OmlfTU)

These packages were built from this fork and tested on Ubuntu 20.04 x86_64.

### Verified Runtime

```text id="xvm5f6"
Ubuntu 20.04 x86_64
glibc 2.31
```

The following functionality has been verified:

```text id="j20hfz"
GUI
FlClashCore
Helper Service
systemd integration
Profile loading
TUN mode
Automatic routing
Proxy traffic
```

### Package Notes

* `.deb`: recommended for Ubuntu/Debian-based distributions.
* `.rpm`: provided for RPM-based distributions.
* `.AppImage`: portable package that can be run without installation.

For AppImage:

```bash id="h8rr9q"
chmod +x FlClash-*.AppImage
./FlClash-*.AppImage
```

For DEB:

```bash id="7x46z0"
sudo apt install ./FlClash-*.deb
```

The prebuilt packages are provided for convenience. If you prefer to build from source, see the Ubuntu 20.04 compatibility and build instructions below.


## Ubuntu 20.04 Compatibility

This fork has been tested on **Ubuntu 20.04 x86_64 with glibc 2.31**.

The upstream Linux binary may require a newer glibc version, such as:

```text id="sv8mol"
GLIBC_2.34
```

and therefore may not run directly on Ubuntu 20.04.

Building FlClash locally on Ubuntu 20.04 produces binaries compatible with the system glibc version.

### Tested Environment

```text id="3l1mu7"
Ubuntu      20.04 x86_64
glibc       2.31
GLib        2.64.x

Flutter     3.47.1
Dart        3.13.1
Rust        1.95.0
```

---

# 1. Required Ubuntu 20.04 Source Compatibility Fixes

These changes are required to compile the current FlClash source on Ubuntu 20.04.

The affected file is:

```text id="d5legl"
plugins/wifi_ssid/linux/wifi_ssid_plugin.cc
```

## 1.1 Support GLib < 2.70

The original code uses:

```cpp id="bj8plz"
g_spawn_check_wait_status(...)
```

However, `g_spawn_check_wait_status()` is only available in newer GLib versions.

Ubuntu 20.04 ships with GLib 2.64.x, where the older API must be used:

```cpp id="jwglog"
g_spawn_check_exit_status(...)
```

The compatibility fix is:

```cpp id="7prym8"
#if GLIB_CHECK_VERSION(2, 70, 0)
  if (!g_spawn_check_wait_status(wait_status, &error)) {
#else
  if (!g_spawn_check_exit_status(wait_status, &error)) {
#endif
    return nullptr;
  }
```

This results in:

```text id="uwnnd7"
GLib >= 2.70  -> g_spawn_check_wait_status()
GLib <  2.70  -> g_spawn_check_exit_status()
```

This allows Ubuntu 20.04 to compile the plugin while still using the newer API on recent Linux distributions.

## 1.2 Fix `g_steal_pointer()` C++ Type Conversion

Two explicit casts are required when compiling with the Ubuntu 20.04 C++ toolchain.

Change:

```cpp id="z80nsk"
return g_steal_pointer(&cached);
```

to:

```cpp id="b5brxc"
return static_cast<GVariant*>(g_steal_pointer(&cached));
```

and change:

```cpp id="k73m8p"
return g_steal_pointer(&ssid);
```

to:

```cpp id="13asox"
return static_cast<gchar*>(g_steal_pointer(&ssid));
```

Without these explicit casts, compilation may fail because `g_steal_pointer()` returns a generic pointer which is not implicitly convertible to the expected C++ pointer type.

### Summary of Required Source Changes

Only the following file needs to be modified for the GLib compatibility fix:

```text id="wx2qbf"
plugins/wifi_ssid/linux/wifi_ssid_plugin.cc
```

The three changes are:

```text id="8acew1"
1. GVariant* explicit cast
2. GLib < 2.70 fallback for g_spawn_check_wait_status()
3. gchar* explicit cast
```

---

# 2. Optional SQLite Build Workaround

This modification is **not required specifically because of Ubuntu 20.04**.

It is an optional workaround for environments where the Dart `sqlite3` native asset cannot download its prebuilt native library from GitHub.

If the normal SQLite native asset download works correctly, this section can be ignored.

## 2.1 Vendor the SQLite Amalgamation Source

Download the official SQLite amalgamation source and place it under:

```text id="qzw0p8"
third_party/sqlite/
├── sqlite3.c
├── sqlite3.h
└── sqlite3ext.h
```

The version tested during the Ubuntu 20.04 build was:

```text id="k7a3ab"
SQLite 3.53.4
```

## 2.2 Configure `sqlite3` to Build from Source

Add the following configuration to the root `pubspec.yaml`:

```yaml id="awhw0g"
hooks:
  user_defines:
    sqlite3:
      source: source
      path: third_party/sqlite/sqlite3.c
```

This causes the SQLite native library to be compiled locally instead of downloading a prebuilt `.so`.

The locally compiled library was verified to require only approximately:

```text id="llcj8m"
GLIBC_2.28
```

which is compatible with Ubuntu 20.04's:

```text id="zjvrfk"
GLIBC_2.31
```

### Important

The SQLite source build is an **optional build workaround**.

It should not be confused with the required `wifi_ssid` GLib compatibility fix.

```text id="ak3i4u"
wifi_ssid fix      -> required for Ubuntu 20.04 source compatibility

SQLite source build -> optional workaround when native asset download fails
```

---

# Ubuntu 20.04 Build Dependencies

Install the required Linux build dependencies:

```bash id="fhuqyy"
sudo apt update

sudo apt install -y \
  curl \
  wget \
  git \
  unzip \
  xz-utils \
  zip \
  build-essential \
  clang \
  cmake \
  ninja-build \
  pkg-config \
  libgtk-3-dev \
  liblzma-dev \
  libglu1-mesa \
  libayatana-appindicator3-dev
```

`libayatana-appindicator3-dev` is required for Linux tray/application-indicator support.

A CMake warning such as:

```text id="mhgrit"
Could NOT find JNI
```

does not prevent the Linux desktop build from completing.

---

# Flutter

The tested version is:

```text id="2ucbwv"
Flutter 3.47.1
Dart 3.13.1
```

After switching Flutter versions, refresh dependencies:

```bash id="6hwll3"
rm -rf .dart_tool
flutter pub get
```

---

# Rust

The Rust component was built using:

```text id="cmv63x"
Rust 1.95.0
```

Install the required toolchain with:

```bash id="mren77"
rustup toolchain install 1.95.0
rustup target add x86_64-unknown-linux-gnu --toolchain 1.95.0
```

---

# Go

FlClashCore requires Go.

Verify the installation with:

```bash id="3jatky"
go version
```

It is recommended to use the Go version specified by the current upstream CI workflow.

---

# Build

Install Dart/Flutter dependencies:

```bash id="cqb7q6"
flutter pub get
```

Then build the Linux release:

```bash id="58ntcp"
flutter build linux --release \
  --dart-define-from-file=env.json
```

The resulting bundle is located at:

```text id="ongm02"
build/linux/x64/release/bundle/
```

---

# Compatibility Verification

The locally built Ubuntu 20.04 bundle was checked for ELF/glibc version requirements.

Representative maximum glibc requirements were:

```text id="6grk9u"
FlClashHelperService      GLIBC_2.30
librust_api.so            GLIBC_2.30
libsqlite3.so             GLIBC_2.28
libflutter_linux_gtk.so   GLIBC_2.18
FlClashCore               statically linked
```

The resulting build therefore requires at most approximately:

```text id="bz8d6q"
GLIBC_2.30
```

Ubuntu 20.04 provides:

```text id="7zhk8d"
GLIBC_2.31
```

so the locally built application is compatible with Ubuntu 20.04.

---

# Runtime Verification

The Ubuntu 20.04 build has been tested successfully with:

```text id="wzvzxe"
FlClash GUI               PASS
FlClashCore               PASS
GUI/Core IPC              PASS
Helper Service            PASS
systemd integration       PASS
Profile loading           PASS
TUN interface             PASS
Automatic routing         PASS
Proxy traffic             PASS
```

TUN mode successfully creates the virtual interface and installs the required Linux policy-routing rules.

---

# Notes

There are two separate compatibility topics documented above:

### Required Ubuntu 20.04 compatibility fix

Modify:

```text id="y03rqr"
plugins/wifi_ssid/linux/wifi_ssid_plugin.cc
```

to support GLib 2.64 and the Ubuntu 20.04 C++ toolchain.

### Optional build workaround

Build SQLite from its amalgamation source when the `sqlite3` package cannot download its native asset.

This workaround is not inherently required by Ubuntu 20.04.

Finally, these source changes do not automatically make upstream prebuilt Linux packages compatible with Ubuntu 20.04.

Binary glibc compatibility depends on the environment used to build the release artifact. Official Ubuntu 20.04-compatible binaries therefore need to be built against a sufficiently old glibc/sysroot.
