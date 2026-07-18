# DroidconKeSwift — Swift Android App

Building Droidconke native Android app entirely in Swift 6.3+, using the official
Swift Android SDK and `swift-java` for JNI/Android interop.

---

## Requirements

- **Swift 6.3+** toolchain (`swift --version`), managed via `swiftly` or
  direct install
- **Swift SDK for Android** installed and registered:
  ```bash
  swift sdk list   # should list an android target
  ```
- **Android Studio** (latest stable)
- **Android NDK** with `ANDROID_NDK_HOME` set
- **Android SDK** with `ANDROID_HOME` set, min SDK **28** (required by the
  Swift Android SDK target)
- **`swift-java`** plugin available for JNI binding generation
- A device or emulator covering at least `arm64-v8a` and `x86_64`

---

## Chapters

Each chapter lives on its own branch and builds on the previous one. See each branch's README for full
step-by-step instructions.

| Chapter | Branch | Summary |
|---|---|---|
| 1 | `chapter-1` | Scaffold a standard Kotlin/Compose Android app and validate it runs cleanly, with an empty `jniLibs/` folder structure in place. No native code yet. |
| 2 | `chapter-2` | Build a standalone Swift package, cross-compile it for Android (`arm64-v8a`, `x86_64`), and generate JNI bindings with `swift-java`. No Android project dependency. |
| 3 | `chapter-3` | Integrate the two: copy the compiled `.so` files and generated bindings into the Android app's `jniLibs/`, load the library, and call Swift logic from Compose. |

More chapters will be added as the app grows past "Hello World" into real
Droidconke features.