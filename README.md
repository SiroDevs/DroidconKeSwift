# DroidconKeSwift — Swift Android App

Building Droidconke native Android app entirely in Swift 6.3+, using the official
Swift Android SDK and `swift-java` for JNI/Android interop.

---

# DroidconKe — Chapter 2: Swift Package

A standalone Swift package holding logic to be cross-compiled for Android
and consumed from a Kotlin/Compose app via JNI. Built and validated
independently of the Android app — this branch has no Android project
dependency. Wiring it into the app happens on `chapter-3`.

## Requirements

- Swift 6.3+ toolchain (`swift --version`)
- Swift SDK for Android installed:
  ```bash
  swift sdk list   # should show an android target
  ```
- `ANDROID_NDK_HOME` and `ANDROID_HOME` set
- `swift-java` plugin available for JNI binding generation

## Steps

### 1. Create the package

```bash
mkdir swift && cd swift
swift package init --type library --name DroidconKeSwift
```

### 2. Write the logic

`Sources/DroidconKeSwift/DroidconKeSwift.swift`:

```swift
public struct Greetings {
    public init() {}

    public func greet(_ name: String) -> String {
        return "Hello, \(name) from DroidconKe Swift!"
    }
}
```

Keep this package UI-free — it's a pure logic layer, callable from either
platform. No SwiftUI, no platform-specific view code.

### 3. Verify it builds for the host

```bash
swift build
.build/debug/DroidconKeSwiftTests   # if you added tests
```

### 4. Cross-compile for Android ABIs

Build once per architecture your app needs (typically both):

```bash
# Physical devices
swift build --swift-sdk aarch64-unknown-linux-android28 \
  --product DroidconKeSwift --configuration release --static-swift-stdlib

# Emulator
swift build --swift-sdk x86_64-unknown-linux-android28 \
  --product DroidconKeSwift --configuration release --static-swift-stdlib
```

Verify output:

```bash
file .build/aarch64-unknown-linux-android28/release/DroidconKeSwift.so
file .build/x86_64-unknown-linux-android28/release/DroidconKeSwift.so
```

### 5. Generate JNI bindings

```bash
swift package plugin swift-java configure \
  --output-directory ./generated-bindings

swift package plugin swift-java generate-jni \
  --output-directory ./generated-bindings
```

This produces the Kotlin/Java wrapper class(es) (e.g. `Greeteings.kt`) that
expose your Swift API to the JVM side — no hand-written JNI glue needed.

> `swift-java` is under active development post-6.3; flag names may drift
> between SDK versions. Check `swift package plugin swift-java --help`
> against your installed toolchain if a command above doesn't match.

## Troubleshooting: NDK not linked into the Swift SDK bundle

If a cross-compile build succeeds but prints these warnings:

```
warning: no such SDK: .../swift-android/ndk-sysroot
<unknown>:0: warning: libc not found for 'aarch64-unknown-linux-android28'; C stdlib may be unavailable
```

the Android Swift SDK artifact bundle has been installed, but the NDK was
never linked into it. Apple doesn't bundle the NDK inside the SDK — it has
to be wired in manually with a setup script, once, per SDK version
installed.

Fix (macOS):

```bash
cd ~/Library/org.swift.swiftpm/swift-sdks/swift-6.3.2-RELEASE_android.artifactbundle/swift-android/

# Point at your existing NDK using an ABSOLUTE path — a relative or ~-prefixed
# path will fail with "ANDROID_NDK_HOME not found: .../toolchains/llvm/prebuilt"
export ANDROID_NDK_HOME=$HOME/Library/Android/sdk/ndk/28.2.13676358

# Sanity check the path resolves before running setup:
ls $ANDROID_NDK_HOME/toolchains/llvm/prebuilt

./scripts/setup-android-sdk.sh
```

Fix (Linux) — same idea, different bundle location:

```bash
cd ~/.swiftpm/swift-sdks/swift-6.3.2-RELEASE_android.artifactbundle/swift-android/

# Absolute path to wherever Android Studio (or sdkmanager) installed the NDK
export ANDROID_NDK_HOME=$HOME/Android/Sdk/ndk/28.2.13676358

ls $ANDROID_NDK_HOME/toolchains/llvm/prebuilt

./scripts/setup-android-sdk.sh
```

Fix (Windows) — treat this as best-effort:

```powershell
cd "$env:LOCALAPPDATA\org.swift.swiftpm\swift-sdks\swift-6.3.2-RELEASE_android.artifactbundle\swift-android"

# Absolute path to wherever Android Studio installed the NDK
$env:ANDROID_NDK_HOME = "$env:LOCALAPPDATA\Android\Sdk\ndk\28.2.13676358"

Get-ChildItem "$env:ANDROID_NDK_HOME\toolchains\llvm\prebuilt"

.\scripts\setup-android-sdk.ps1
```

> As of early 2026, Windows support for the Swift SDK for Android was
> still catching up to macOS/Linux, and the SDK bundle install path,
> script name/extension, and even whether a `.ps1` equivalent of
> `setup-android-sdk.sh` ships at all may differ from what's shown above.
> If this doesn't match what you see under
> `swift sdk list` / the bundle folder on your machine, check
> [swift.org/install](https://www.swift.org/install) for the current
> Windows-specific instructions rather than assuming this guide is
> accurate — Windows is the least-tested platform for this SDK.

If you don't already have an NDK installed, download the LTS release
directly into the SDK bundle folder instead:

```bash
curl -fSL -o ndk.zip https://dl.google.com/android/repository/android-ndk-r27d-Darwin.zip   # macOS
curl -fSL -o ndk.zip https://dl.google.com/android/repository/android-ndk-r27d-Linux.zip     # Linux
unzip -qo ndk.zip
export ANDROID_NDK_HOME=$PWD/android-ndk-r27d
./scripts/setup-android-sdk.sh
```

Notes:
- **NDK r27d or later is required.** Android Studio-managed NDKs like
  `28.2.13676358` satisfy this — no need to download a separate one if you
  already have a recent version, on any OS.
- `ANDROID_NDK_HOME` must be an **absolute path** on every platform.
  `export ANDROID_NDK_HOME=Developer/Android/Sdk/ndk/...` will silently
  resolve relative to your current directory, not `$HOME`, and the script
  will fail to find `toolchains/llvm/prebuilt`.
- Once the setup script completes successfully, you can unset
  `ANDROID_NDK_HOME` — the SDK bundle keeps its own internal reference.
- Rerun the Chapter 2 Step 4 build afterward; both warnings should be
  gone and the `.so` file should build cleanly.

## Next

Integration into the Android app (copying `.so` files and JNI bindings
into `jniLibs/`, loading the library from Compose) happens on
`chapter-3` — see that branch's README.

---

## Notes

- Rebuild both the `.so` and the JNI bindings together whenever the Swift
  API changes — a stale binding against a newer `.so` (or vice versa) is a
  common source of silent crashes.
- `--static-swift-stdlib` simplifies deployment by avoiding the need to
  ship Swift's dynamic runtime libs separately, at the cost of a larger
  `.so`.
- Over 25% of Swift Package Index packages already build for Android, but
  check any third-party dependency you add here before relying on it.