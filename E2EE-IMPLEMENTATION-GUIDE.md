# Adding E2EE to jitsi-meet-flutter-sdk — Implementation Guide

This document describes how to add end-to-end encryption (E2EE) for audio and
video to the Jitsi Meet Flutter SDK, for **Android and iOS**, including what is
already implemented in this repository and what remains to be built in the
native stack. It is written so the work can be continued on macOS (required for
the iOS build).

---

## 1. Status

| Layer | State |
|---|---|
| Flutter plugin API (Dart + method channels) | ✅ **Done** (this repo, see §6) |
| Android plugin handlers (`JitsiMeetPlugin.kt`) | ✅ **Done** — uses `BroadcastIntentHelper.buildSetE2EE*` from the custom SDK |
| iOS plugin handlers (`JitsiMeetPlugin.swift`) | ✅ **Done** — compiles against the custom JitsiMeetSDK (§5.4) |
| Frame cryptor in RN WebRTC (Android + iOS) | ✅ **Done** (WP1) — `e2ee-native/react-native-webrtc` fork: JNI trampoline + Java AES-GCM (Android), ObjC++ + CommonCrypto (iOS) |
| lib-jitsi-meet RN key-handler path | ✅ **Done** (WP2) — `modules/e2ee/RNKeyHandler.js` + RN branch in `E2EEncryption.isSupported`; tarball `lib-jitsi-meet-0.0.0.tgz` |
| jitsi-meet mobile external-API commands | ✅ **Done** (WP3) — `SET_E2EE_ENABLED`/`SET_E2EE_KEY` (Android broadcast enum, iOS `ExternalAPI`/`JitsiMeetView`, RN middleware) |
| Custom Android SDK AAR | ✅ **Built** — `org.jitsi.react:jitsi-meet-sdk:13.1.1-e2ee.1` in `e2ee-native/local-maven-repository/releases` |
| Custom iOS SDK framework | ✅ **Built on macOS** — `13.1.1-e2ee.1` xcframework in `e2ee-native/jitsi-meet-ios-sdk-releases` |
| End-to-end verification (Android) | ✅ **Passed** — two emulators, `meet.ffmuc.net`: same key → video both ways; wrong key → video dropped; correct key on rejoin → recovery (see `shots-e2ee/`) |
| End-to-end verification (iOS) | ✅ **Passed** — iOS 26.1 simulator in the same E2EE room as an Android emulator: iOS decrypts and renders Android's encrypted video live (`shots-e2ee/ios-sim-decrypts-android-video.png`). If the simulator stalls loading `config.js` (RN fetch pending > 10 s `loadScript` timeout), erase/reboot the simulator (`xcrun simctl shutdown <udid> && xcrun simctl erase <udid>`) and retry — it is a flaky simulator state, not an E2EE issue (reproduces with the stock SDK). |

### Notes from the macOS build session

- **Gradle file watcher deadlock (macOS)**: the Android SDK build hung in Gradle's native file watcher (`startWatching0`). Fixed by `org.gradle.vfs.watch=false` in `e2ee-native/jitsi-meet/android/gradle.properties`.
- **Metro + symlinks**: `file:` (symlink) dependencies break Metro resolution — ship the forks as `.tgz` (`npm pack`) and point `package.json` at the tarballs. The react-native-webrtc fork also needed its `prepare` script removed (husky/bob are dev-only; Metro consumes `src/` via the `react-native` field).
- **Flutter/Gradle Java mismatch**: Flutter picked up Android Studio's JBR (Java 25) which Gradle 8.14 rejects — fixed with `flutter config --jdk-dir=<openjdk-17 home>`.
- **Podspec for local iOS consumption**: the generated `JitsiMeetSDK.podspec` in the local releases repo had its `s.source` git URL rewritten to the local repo path (tag `13.1.1-e2ee.1` exists there).
- The full `jitsi-maven-repository` clone is ~53 GB — do **not** clone it; any plain directory works as `MVN_REPO`.
- **Xcode 27 `lipo` regression**: `lipo <file> -verify_arch <arch1> <arch2>` fails with "requires exactly one input file" (single-arch works). This breaks Flutter's `thinFramework` for iOS simulator builds. Workaround applied to the local Flutter SDK (`packages/flutter_tools/lib/src/build_system/targets/darwin.dart` — verify each arch in a loop; delete `bin/cache/flutter_tools.snapshot` to force a tool rebuild). Revert with `git checkout` in the Flutter SDK once Apple/Flutter fix it.
- **iOS simulator flakiness**: the Simulator's RN `fetch` may stall on `config.js` past the 10 s `loadScript` timeout, after which stock jitsi-meet code hits a fatal `Invalid URL: undefined` in `react/features/app/actions.any.ts` (`addTrackStateToURL`). Seen on iOS 17.0 and 26.1 sims, two servers, **and with the stock JitsiMeetSDK 13.1.1** — while a bare `URLSession` app on the same simulator fetches `config.js` in 0.3 s. Fix in practice: `xcrun simctl shutdown <udid> && xcrun simctl erase <udid>`, reboot, reinstall — after which the conference joins and E2EE works (verified live, see the status table). For headless iOS runs, build the example with `--dart-define=E2EE_AUTOJOIN=true` (auto-joins with E2EE enabled, skips the prejoin page; also logs a `NETPROBE` dart:io connectivity probe).
- **Android acceptance test (passed, `meet.ffmuc.net`, two emulators)**: same key → remote video both ways (`shots-e2ee/android-same-key-*.png`); wrong key on one side → remote video dropped to avatar (`shots-e2ee/android-wrong-key-deviceB.png`); rejoin with the correct key → decryption recovers immediately (`shots-e2ee/android-recovery-correct-key.png`).

---

## 2. Why the work is at the engine level (summary of findings)

The Flutter SDK is a thin wrapper: the meeting runs inside Jitsi's React Native
engine. E2EE is absent from that engine on mobile:

1. `react-native-webrtc@124.0.8` (pinned by mobile SDK 13.1.1) exposes **no**
   frame-encryption API (`createEncodedStreams`/frame cryptor). Upstream request:
   [react-native-webrtc#1592](https://github.com/react-native-webrtc/react-native-webrtc/issues/1592) — *wontfix*.
2. lib-jitsi-meet's `E2EEncryption.isSupported()` requires insertable streams
   (or `RTCRtpScriptTransform`) — absent on RN — so `conference.toggleE2EE()` is
   a no-op on mobile.
3. The mobile external API (Android `BroadcastAction`/`BroadcastIntentHelper`,
   iOS `JitsiMeetView` methods) has **no** E2EE command — verified at
   `mobile-sdk-13.1.1` and latest `mobile-sdk-26.1.0`.
4. The native (mobile) security dialog has no E2EE UI; it is web-only.

**Key enabling discovery** (verified on the exact pinned binaries): the Jitsi
WebRTC build that ships inside the mobile SDK *already contains* the native
frame-encryption hooks:

- Android (`org.jitsi:webrtc:124.0.0` AAR on Maven Central): `libwebrtc.jar`
  contains `org.webrtc.FrameEncryptor`, `org.webrtc.FrameDecryptor`,
  `org.webrtc.CryptoOptions`, and `libjingle_peerconnection_so.so` exports the
  JNI entry points `Java_org_webrtc_RtpSender_nativeSetFrameEncryptor` /
  `Java_org_webrtc_RtpReceiver_nativeSetFrameDecryptor`.
- iOS (`JitsiWebRTC` 124.0.2 pod): built from the same
  [jitsi/webrtc](https://github.com/jitsi/webrtc) repo; the ObjC crypto headers
  (`api/crypto/frame_encryptor_interface.h` etc.) are part of the build. Verify
  on the Mac (§4.1 checklist).

⇒ **No WebRTC rebuild is needed.** The work is glue + a custom
encryptor/decryptor implementation.

---

## 3. Design

### 3.1 E2EE model: externally managed shared key

We implement the *shared key* model (same idea as the 2020 blog post's
`e2eekey`): the app provides one secret key; all participants join with it;
anyone without it sees garbage. This deliberately avoids Olm key exchange
(`window.Olm` does not exist on RN) — it is the only mode whose support check
passes without Olm:

```js
// lib-jitsi-meet E2EEncryption.isSupported(config):
if (!e2ee.externallyManagedKey && !OlmAdapter.isSupported()) return false;
```

The Flutter plugin forces `e2ee.externallyManagedKey: true` in the conference
config whenever E2EE is requested (already implemented — §6).

Key distribution is the app's responsibility (out of band). Rotation = call
`setE2EEKey` again with a new key (key index increments).

### 3.2 Frame format & interop decision

Two options for the custom cryptor's wire format:

- **Phase 1 (build this first): mobile-only island.** All participants are our
  Flutter apps; any correct AES-GCM frame format works. Recommended format:
  mirror Jitsi's *JFrame* layout (IV from SSRC+RTP timestamp+frame counter,
  12-byte IV, 16-byte GCM tag, KID trailer; leave VP8 payload header and Opus
  TOC byte unencrypted) so Phase 2 is a delta, not a rewrite.
- **Phase 2 (optional): interop with Jitsi web E2EE clients.** Requires a
  byte-exact port of lib-jitsi-meet's JFrame + key handling:
  `importKey` = HKDF(SHA-256) over the raw key bytes, `deriveKeys` → AES-GCM-128
  (`modules/e2ee/crypto-utils.ts`), per-participant key ratcheting
  (`modules/e2ee/KeyHandler.js`, `E2EEContext.js`). Only needed if browsers must
  join E2EE sessions with the mobile apps.

### 3.3 Layer diagram

```
Flutter app
  │  JitsiMeetConferenceOptions(e2eeEnabled, e2eeKey) / jitsiMeet.setE2EEKey()
  ▼
jitsi-meet-flutter-sdk (this repo)                        [DONE]
  │  MethodChannel: join(+e2ee opts), setE2EEEnabled, setE2EEKey
  ▼
Android: Intent org.jitsi.meet.SET_E2EE_*  (LocalBroadcastManager)   [DONE, plugin]
iOS:     JitsiMeetView.setE2EEEnabled/setE2EEKey                     [WP3]
  ▼
jitsi-meet (RN bundle in the native SDK)
  react/features/mobile/external-api/middleware.ts  ← add listeners  [WP3]
  react/features/e2ee/* (existing actions/middleware)
  ▼
lib-jitsi-meet  E2EEncryption → RN key handler (new)                 [WP2]
  ▼
react-native-webrtc fork: RTCFrameCryptor JS → native module         [WP1]
  ▼
org.webrtc.FrameEncryptor / FrameDecryptor (present in the binaries) → C++
  AES-GCM encryptor/decryptor (custom, ours)
```

---

## 4. Work packages

Repos and pinned versions (fork all of these):

| Component | Repo | Version/tag |
|---|---|---|
| jitsi-meet (mobile SDK source) | github.com/jitsi/jitsi-meet | `mobile-sdk-13.1.1` |
| lib-jitsi-meet (bundled in the above) | github.com/jitsi/lib-jitsi-meet | `v2167.0.0+9419dc17` (see jitsi-meet `package.json`) |
| react-native-webrtc | github.com/react-native-webrtc/react-native-webrtc | `124.0.8` |
| jitsi-meet-flutter-sdk | this repo | local clone |

Reference implementations to port from (both permissively licensed):

- [`@livekit/react-native-webrtc`](https://github.com/livekit/react-native-webrtc)
  (master): `src/RTCFrameCryptor.ts`, `src/RTCFrameCryptorFactory.ts`,
  `android/src/main/java/com/oney/WebRTCModule/RTCCryptoManager.java`,
  `ios/RCTWebRTC/WebRTCModule+RTCFrameCryptor.m` — an RN-ready frame cryptor.
- [`flutter_webrtc`](https://github.com/flutter-webrtc/flutter-webrtc) (main):
  `lib/src/native/frame_cryptor_impl.dart`,
  `android/src/main/java/com/cloudwebrtc/webrtc/FlutterRTCFrameCryptor.java`,
  `common/cpp/src/flutter_frame_cryptor.cc` (shared C++ AES-GCM),
  `common/darwin/Classes/FlutterRTCFrameCryptor.m` (ObjC side).

### 4.1 WP1 — react-native-webrtc fork: frame cryptor module

Goal: a JS-callable API in the RN WebRTC module, e.g.:

```ts
// react-native-webrtc fork, e.g. src/RTCFrameCryptor.ts
frameCryptorFactoryCreateFrameCryptor(participantId, rtpSenderId, side /* 'sender'|'receiver' */)
frameCryptorSetKey(cryptorId, keyIndex, keyBytes /* base64 */)
frameCryptorSetEnabled(cryptorId, enabled)
// + event 'frameCryptionStateChanged' (participantId, state) for diagnostics
```

Android (`android/src/main/java/com/oney/WebRTCModule/`):

1. `E2EEFrameCryptor.java` — Java class implementing `org.webrtc.FrameEncryptor`
   / `org.webrtc.FrameDecryptor`. These interfaces only expose
   `getNativeFrameEncryptor()` (a native pointer), so each Java object wraps a
   native peer created via JNI:
   - New C++ file (e.g. `android/src/main/cpp/FrameCryptorJni.cpp`):
     - class `AesGcmFrameEncryptor : public webrtc::FrameEncryptorInterface`
       implementing `Encrypt(...)` / `GetMaxCiphertextByteSize(...)`;
       `AesGcmFrameDecryptor : public webrtc::FrameDecryptorInterface`
       implementing `Decrypt(...)`.
     - AES-128-GCM, IV = f(ssrc, rtpTimestamp, frameCounter), 12-byte IV and
       16-byte tag appended as a trailer together with the key index (KID).
       Do **not** encrypt the VP8 payload descriptor (10 B keyframe / 3 B
       interframe) nor the 1-byte Opus TOC — keeps the SFU happy and matches
       JFrame. Use WebRTC's bundled crypto (`rtc_base/ssl_adapter`, BoringSSL
       symbols are already linked in libjingle) or Android's `javax.crypto`
       called through JNI (simpler, slightly slower).
     - JNI factories returning `jlong` native pointers.
   - `RtpSender.setFrameEncryptor(...)` / `RtpReceiver.setFrameDecryptor(...)`
     already exist in the AAR (verified) — call them from the module.
2. `E2EECryptoModule.java` — `@ReactModule` exposing the 3 methods above to JS;
   keep a `Map<String, cryptor>` registry; emit state events via the RN device
   event emitter.
3. Register the module in the package list (`WebRTCModulePackage` /
   `WebRTCModulePackageAdapter` — check how the fork registers modules).
4. CMake: add the cpp file to `android/src/main/cpp/CMakeLists.txt` (the project
   already builds JNI code — `WebRTCModule` has a cpp dir; link against the
   WebRTC AAR's headers — get headers from the `webrtc-124.0.0-sources.jar` +
   the jitsi/webrtc repo at the matching commit).

iOS (`ios/RCTWebRTC/`):

1. `WebRTCModule+RTCFrameCryptor.m` — ObjC++ RCT module with the same 3 methods.
   Implement the cryptor in C++ (`webrtc::FrameEncryptorInterface`) and attach
   via `RTCRtpSender.frameEncryptor` / `RTCRtpReceiver.frameDecryptor`
   (`JitsiWebRTC` 124 — verify header presence, see checklist below).
   Reference: LiveKit's `WebRTCModule+RTCFrameCryptor.m` and flutter_webrtc's
   `FlutterRTCFrameCryptor.m`.
2. AES-GCM via CommonCrypto (`CCCryptorGCM...`) or BoringSSL symbols in the
   framework.

**Verify-first checklist before writing code:**

- [x] Android AAR has `FrameEncryptor`/`FrameDecryptor` + JNI attach points
      (already verified by us on `org.jitsi:webrtc:124.0.0`).
- [ ] On the Mac: `JitsiWebRTC.framework` (from `JitsiWebRTC` 124.0.2 pod)
      headers contain `RTCFrameEncryptor`/`RTCFrameDecryptor` /
      `frame_encryptor_interface.h`. If the ObjC headers are missing, call the
      C++ API directly from `.mm` files (they are in the binary regardless).
- [ ] Confirm how the stock WebRTC AAR/framework was built
      (`github.com/jitsi/webrtc` build scripts) in case a symbol is missing.

### 4.2 WP2 — lib-jitsi-meet: RN key-handler path

Files (in jitsi-meet's node_modules patch or a lib-jitsi-meet fork — jitsi-meet
pins a tarball, so fork lib-jitsi-meet and point `package.json` at it):

1. `modules/e2ee/E2EEncryption.js`
   - `static isSupported(config)`: add RN branch —
     `if (browser.isReactNative()) return Boolean(config.e2ee?.externallyManagedKey);`
   - constructor: on RN with externally managed key, instantiate the new
     `RNKeyHandler` instead of `ExternallyManagedKeyHandler` (which routes
     through `E2EEContext` → insertable streams → would no-op on RN).
2. New `modules/e2ee/RNKeyHandler.js` (model on `ExternallyManagedKeyHandler.js`
   / `KeyHandler.js`):
   - `setKey(keyInfo)`: store `{key, index}`.
   - `setEnabled(enabled)`: iterate the conference's peer connections
     (`conference.getActivePeerConnection()` / TPCs) → for each
     `RTCRtpSender`/`RTCRtpReceiver` (react-native-webrtc objects carry a native
     `_id`) create/attach the native cryptor via the WP1 module; set key +
     enabled state on each.
   - Re-attach when new senders/receivers appear (same events E2EEContext uses:
     TPC `sender`/`receiver` setup — see `E2EEContext.js` `_setupSender` /
     `_setupReceiver` and where they're invoked from `RTC`/`TraceablePeerConnection`).
   - Do **not** use `window.crypto` anywhere (absent on RN) — the raw key string
     goes to the native side (e.g. base64) and derivation happens natively
     (SHA-256 of the passphrase → AES-128 key for Phase 1).

### 4.3 WP3 — jitsi-meet fork: mobile external-API commands

Android (`android/sdk/src/main/java/org/jitsi/meet/sdk/`):

```java
// BroadcastAction.java — add to enum Type:
SET_E2EE_ENABLED("org.jitsi.meet.SET_E2EE_ENABLED"),
SET_E2EE_KEY("org.jitsi.meet.SET_E2EE_KEY");

// BroadcastIntentHelper.java — add:
public static Intent buildSetE2EEEnabledIntent(boolean enabled) {
    Intent intent = new Intent(BroadcastAction.Type.SET_E2EE_ENABLED.getAction());
    intent.putExtra("enabled", enabled);
    return intent;
}
public static Intent buildSetE2EEKeyIntent(String key) {
    Intent intent = new Intent(BroadcastAction.Type.SET_E2EE_KEY.getAction());
    intent.putExtra("key", key);
    return intent;
}

// ExternalAPIModule.java — add to getConstants():
constants.put("SET_E2EE_ENABLED", BroadcastAction.Type.SET_E2EE_ENABLED.getAction());
constants.put("SET_E2EE_KEY", BroadcastAction.Type.SET_E2EE_KEY.getAction());
```

(`BroadcastReceiver` in the SDK forwards any `BroadcastAction` to RN
automatically — no other native change needed on Android.)

iOS (`ios/sdk/src/`):

```objc
// ExternalAPI.m
static NSString * const setE2EEEnabledAction = @"org.jitsi.meet.SET_E2EE_ENABLED";
static NSString * const setE2EEKeyAction = @"org.jitsi.meet.SET_E2EE_KEY";
// add to the constants map and to -supportedEvents, then:
- (void)sendE2EEEnabled:(BOOL)enabled {
    [self sendEventWithName:setE2EEEnabledAction body:@{@"enabled": @(enabled)}];
}
- (void)sendE2EEKey:(NSString*)key {
    [self sendEventWithName:setE2EEKeyAction body:@{@"key": key}];
}

// JitsiMeetView.h/.m — add:
- (void)setE2EEEnabled:(BOOL)enabled {
    ExternalAPI *externalAPI = [[JitsiMeet sharedInstance] getExternalAPI];
    [externalAPI sendE2EEEnabled:enabled];
}
- (void)setE2EEKey:(NSString * _Nonnull)key {
    ExternalAPI *externalAPI = [[JitsiMeet sharedInstance] getExternalAPI];
    [externalAPI sendE2EEKey:key];
}
```

RN side (`react/features/mobile/external-api/middleware.ts`,
`_registerForNativeEvents`):

```ts
eventEmitter.addListener(ExternalAPI.SET_E2EE_ENABLED, ({ enabled }: any) => {
    dispatch(toggleE2EE(enabled));              // existing action — features/e2ee
});
eventEmitter.addListener(ExternalAPI.SET_E2EE_KEY, ({ key }: any) => {
    dispatch(setE2EEKey(key));                  // NEW action, see below
});
```

Do **not** reuse the web `SET_MEDIA_ENCRYPTION_KEY` action — its handler uses
`window.crypto.subtle.importKey`, which does not exist on RN. Instead add a new
action in `react/features/e2ee` (e.g. `SET_E2EE_KEY`) whose middleware case calls
`conference.setE2EEKey(key)` — a new small method on `JitsiConference` that
forwards the string key to the WP2 `RNKeyHandler`. On the RN path,
`TOGGLE_E2EE` → `conference.toggleE2EE()` → `E2EEncryption.setEnabled` →
`RNKeyHandler.setEnabled` (WP2) drives the native cryptors.

Optional but recommended: emit `E2EE_ENABLED_CHANGED` / key-error events back to
native (pattern: existing `sendEvent(store, 'AUDIO_MUTED_CHANGED', ...)`), so the
Flutter SDK can show state. Add to `BroadcastEvent.Type` + iOS
`JitsiMeetViewDelegate` later if needed — Phase 1 can live without it.

### 4.4 WP4 — build & publish the SDKs

Prereqs (both): Node LTS, Yarn, JDK 17. Android add: Android SDK + NDK. iOS add:
macOS + Xcode + CocoaPods.

```sh
git clone --branch mobile-sdk-13.1.1 https://github.com/jitsi/jitsi-meet.git
cd jitsi-meet
# apply WP1 (package.json: point react-native-webrtc at your fork),
#        WP2 (lib-jitsi-meet fork URL), WP3 patches
npm install        # or yarn
```

Android (works on Windows too):

```sh
# expects a jitsi-maven-repository checkout (or pass any dir)
git clone https://github.com/jitsi/jitsi-maven-repository.git ../jitsi-maven-repository
OVERRIDE_SDK_VERSION=13.1.1-e2ee.1 ./android/scripts/release-sdk.sh ../jitsi-maven-repository/releases
# produces + publishes the AAR into that maven repo dir
```

iOS (macOS only):

```sh
git clone https://github.com/jitsi/jitsi-meet-ios-sdk-releases.git ../jitsi-meet-ios-sdk-releases
OVERRIDE_SDK_VERSION=13.1.1-e2ee.1 ./ios/scripts/release-sdk.sh
# builds JitsiMeetSDK.xcframework into ../jitsi-meet-ios-sdk-releases/Frameworks
# and generates JitsiMeetSDK.podspec there
```

Note: the release scripts build the RN bundle as part of the SDK build — the
first build is slow (30–60+ min). If `release-sdk.sh` refuses because the
version dir exists, bump `OVERRIDE_SDK_VERSION`.

---

## 5. Consuming the custom SDKs in this Flutter plugin

5.1 **Android** — `android/build.gradle` of this plugin: add the local maven
repo before jitsi's (or use `mavenLocal()` after copying the artifact there),
and change the dependency:

```gradle
repositories { maven { url '/path/to/jitsi-maven-repository/releases' } } // first
dependencies {
    implementation("org.jitsi.react:jitsi-meet-sdk:13.1.1-e2ee.1") { transitive = true }
}
```

Then in `JitsiMeetPlugin.kt` you may switch the raw intents to the new
`BroadcastIntentHelper.buildSetE2EEEnabledIntent/buildSetE2EEKeyIntent`
(marked with a NOTE in the code).

5.2 **iOS** — point the pod at the local build in your app's `Podfile`:

```ruby
pod 'JitsiMeetSDK', :podspec => '/path/to/jitsi-meet-ios-sdk-releases/JitsiMeetSDK.podspec'
```

(`ios/jitsi_meet_flutter_sdk.podspec` currently pins `JitsiMeetSDK 13.1.1` —
relax it to a version-only or no constraint so the local podspec wins.)

5.3 The plugin's iOS E2EE methods call `JitsiMeetView.setE2EEEnabled/setE2EEKey`,
which only exist in the custom framework — build the iOS app only after WP3/WP4-iOS.

5.4 Until the custom SDKs exist, everything else works unchanged against the
stock SDK 13.1.1 (the E2EE calls are then no-ops — Android compiles because it
uses raw intents; iOS requires the custom SDK to compile, so on iOS gate the two
calls if needed).

---

## 6. Already implemented in this repo (Flutter side)

Dart:

- `JitsiMeetConferenceOptions.e2eeEnabled` / `.e2eeKey`
  (`lib/src/jitsi_meet_conference_options.dart`).
- `JitsiMeet.setE2EEEnabled(bool)` / `JitsiMeet.setE2EEKey(String)`
  (`lib/src/jitsi_meet.dart`, `lib/src/jitsi_meet_platform_interface.dart`,
  `lib/src/jitsi_meet_method_channel.dart`).
- Join-time automation: when E2EE is requested via options, the key and the
  enable flag are applied automatically on `conferenceJoined` (ordering-safe).
- `flutter analyze` clean, `flutter test` green, example APK builds.

Android (`android/src/main/kotlin/.../JitsiMeetPlugin.kt`):

- `join` forces `configOverrides.e2ee.externallyManagedKey = true` when E2EE is
  requested (required — otherwise lib-jitsi-meet reports E2EE unsupported on RN).
- `setE2EEEnabled` / `setE2EEKey` broadcast `org.jitsi.meet.SET_E2EE_ENABLED` /
  `org.jitsi.meet.SET_E2EE_KEY` intents.

iOS (`ios/Classes/JitsiMeetPlugin.swift`):

- Same forcing of `e2ee.externallyManagedKey` at join.
- `setE2EEEnabled` / `setE2EEKey` → `JitsiMeetView` (custom SDK, WP3).

App usage:

```dart
var options = JitsiMeetConferenceOptions(
  serverURL: 'https://meet.example.com',
  room: 'secret-room',
  e2eeEnabled: true,
  e2eeKey: sharedKey, // distributed out-of-band to all participants
);
await jitsiMeet.join(options, listener);
// later, mid-call:
await jitsiMeet.setE2EEEnabled(false);
await jitsiMeet.setE2EEKey(newKey); // rotate
```

---

## 7. Test plan

Per layer, smallest first:

1. **WP1 standalone**: tiny RN/Android test harness — create PC, attach cryptor,
   feed a frame through `encrypt`→`decrypt`, assert round-trip; assert wrong key
   fails auth.
2. **WP2/WP3**: run the patched jitsi-meet app from source
   (`./android/scripts/run-packager.sh` + the app), call the external API from
   native test code, watch logcat for `E2EE will be enabled` and no
   "platform is not supported" warnings.
3. **End-to-end (the acceptance test)**:
   - Two devices/emulators running a Flutter app on this plugin, same room,
     same `e2eeKey` → media flows normally.
   - Negative: one joins with a different key → that participant sees/hears
     garbage (and recovers when the key is fixed).
   - Toggle off/on mid-call via `setE2EEEnabled` recovers cleanly.
   - Late joiner with the key decrypts immediately.
   - Harness available locally: an Android 15 emulator + a headless Chromium
     client (see `../jitsi_e2ee_webview_poc/tool/` for the adb/CDP scripts we
     used to validate the WebView path — same technique applies).

## 8. Limitations & risks

- E2EE covers audio/video/screen-share only — never chat/polls (Jitsi design).
- Shared-key model: key management (distribution, rotation, revocation) is the
  app's responsibility. Per-participant keys (Olm) can come later as WP5.
- Mobile-only island until Phase 2 (JFrame+HKDF+ratchet exact port) is done.
- Performance: AES-GCM per frame in our own code — measure CPU/battery on
  low-end devices (BoringSSL/CommonCrypto are hardware-accelerated; avoid
  per-frame JNI crossings by doing crypto in C++).
- Custom native SDK builds must be re-based on new Jitsi releases manually.
- The store binaries (`org.jitsi:webrtc`, `JitsiWebRTC`) are Jitsi-controlled —
  if a symbol is ever missing, rebuild WebRTC from
  [jitsi/webrtc](https://github.com/jitsi/webrtc) (big job; not needed per the
  §4.1 checklist).

## 9. References

- Jitsi E2EE design doc (JFrame format, key handling):
  <https://github.com/jitsi/lib-jitsi-meet/blob/master/doc/e2ee.md>
- lib-jitsi-meet sources (v2167): `modules/e2ee/{E2EEncryption.js,
  ExternallyManagedKeyHandler.js, KeyHandler.js, E2EEContext.js,
  crypto-utils.ts}`
- jitsi-meet mobile external API: `react/features/mobile/external-api/middleware.ts`,
  `android/sdk/src/main/java/org/jitsi/meet/sdk/{BroadcastAction,BroadcastIntentHelper,ExternalAPIModule,BroadcastReceiver}.java`,
  `ios/sdk/src/{ExternalAPI.m,JitsiMeetView.{h,m}}`
- LiveKit RN frame cryptor (port source):
  <https://github.com/livekit/react-native-webrtc> —
  `src/RTCFrameCryptor.ts`, `android/.../RTCCryptoManager.java`,
  `ios/RCTWebRTC/WebRTCModule+RTCFrameCryptor.m`
- flutter_webrtc frame cryptor (port source):
  <https://github.com/flutter-webrtc/flutter-webrtc> —
  `common/cpp/src/flutter_frame_cryptor.cc`,
  `android/.../FlutterRTCFrameCryptor.java`, `common/darwin/.../FlutterRTCFrameCryptor.m`
- Jitsi mobile E2EE groundwork (Olm on RN, 2022 — not needed for Phase 1):
  <https://jitsi.org/blog/a-stepping-stone-towards-end-to-end-encryption-on-mobile/>
