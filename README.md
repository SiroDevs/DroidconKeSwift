# DroidconKeSwift — Swift Android App

Building Droidconke native Android app entirely in Swift 6.3+, using the official
Swift Android SDK and `swift-java` for JNI/Android interop.

---

# Chapter 3: Integrating Android app and the Swift Package

Merges the Chapter 1 Android app scaffold with the Chapter 2 Swift package,
wiring the compiled Swift logic into the Compose UI via JNI.

## Steps

1. Add the empty `jniLibs/arm64-v8a` and `jniLibs/x86_64` folders now, and
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
2. Copy the compiled `.so` files from the Swift package build output into
   the matching `jniLibs/<abi>/` folder:
   ```bash
   cp swift/swift/.build/aarch64-unknown-linux-android28/release/DroidconKeSwift.so \
      app/src/main/jniLibs/arm64-v8a/

   cp swift/swift/.build/x86_64-unknown-linux-android28/release/DroidconKeSwift.so \
      app/src/main/jniLibs/x86_64/
   ```
3. Copy `libc++_shared.so` from the NDK into the same folders (unless the
   Swift build was fully statically linked):
   ```bash
   cp $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/*/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so \
      app/src/main/jniLibs/arm64-v8a/
   ```
4. Copy the generated JNI binding file (e.g. `Greetings.kt`) from
   `swift/swift/generated-bindings/` into `app/src/main/java/...`,
   matching its package declaration.
5. Load the library and call it from Compose, replacing the Chapter 1
   placeholder:
   ```kotlin
   companion object {
       init { System.loadLibrary("DroidconKeSwift") }
   }
   ```
   val greeting = remember { Greetings().greet("Android") }
   Text(text = greeting)
   ```
6. Rebuild and run:
   ```bash
   ./gradlew assembleDebug
   adb install -r app/build/outputs/apk/debug/app-debug.apk
   ```

Expected result: **"Hello, Android from Swift!"** rendered in the same
Compose UI slot that showed the placeholder in Phase 1.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `UnsatisfiedLinkError` at runtime | Missing `.so` for that device's ABI, or `libc++_shared.so` not bundled |
| Crash only on emulator | Emulator is x86_64 but only the arm64 `.so` was built/copied |
| Symbol mismatch / crash on call | Binding file generated from a different Swift source version than the `.so` — rebuild both together |

## Notes

- The UI layer is still entirely Kotlin/Compose. Swift owns the logic
  called through JNI only — SwiftUI is never involved.
- If the Swift API changes, rebuild both the `.so` and the JNI bindings
  together on `chapter-2` before re-copying them here.