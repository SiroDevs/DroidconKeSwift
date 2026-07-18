# DroidconKeSwift — Swift Android App

Building Droidconke native Android app entirely in Swift 6.3+, using the official
Swift Android SDK and `swift-java` for JNI/Android interop.

---

# Chapter 1: Android App Scaffold

A standard Android app (Kotlin + Jetpack Compose), validated end to end
before any native Swift code is introduced.

## Requirements

- Android Studio (latest stable)
- Min SDK: **28** (required by the Swift Android SDK target)
- Kotlin, Jetpack Compose (default Empty Activity template)
- A device or emulator for `arm64-v8a` and/or `x86_64`

## Steps

1. New Project → **Empty Activity (Compose)**, min SDK 28.
2. In `MainActivity.kt`, render a placeholder string in Compose:
   ```kotlin
   Text(text = "Hello, world!")
   ```
3. Run on both an x86_64 emulator and (if available) an arm64 device.
   Confirm the app builds and launches cleanly before touching native code.
4. Add the empty `jniLibs/arm64-v8a` and `jniLibs/x86_64` folders now, and
   confirm Gradle picks them up:
   ```kotlin
   android {
       sourceSets {
           getByName("main") {
               jniLibs.srcDirs("src/main/jniLibs")
           }
       }
   }
   ```

---

## Notes

- The UI layer is **always Kotlin/Compose** — SwiftUI does not run on
  Android. This branch has no native code at all yet; that's intentional.
- Next branch: `chapter-2` (Swift package, no Android
  dependency).