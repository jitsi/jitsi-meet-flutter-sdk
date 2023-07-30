# Jitsi Meet Flutter SDK

A flutter plugin that serves as a Jitsi Meet flutter SDK.


## Installation

### Add dependency

Add this to the `pubspec.yaml` file in your project:

```yaml
dependencies:
    jitsi_meet_flutter_sdk: '^0.0.1'
```

### Install 

Install the packages from the terminal:

```bash
$ pub get
```

### Import files

Import the following files into your dart code:

```dart
import 'package:jitsi_meet_flutter_sdk/jitsi_meet.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_conference_options.dart';
```

### Usage

#### Join meeting

Firstly, create a `JitsiMeet` object, then call the method `join` from it with a `JitsiMeetConferenceOptions` object

```dart
var jitsiMeet = JitsiMeet();
var options = JitsiMeetConferenceOptions(room: 'jitsiIsAwesome');
jitsiMeet.join(options);
```

## Configuration

### 

### iOS

Make sure in `Podfile` from `ios` directory you set the ios version `12.4 or higher` 

```
platform :ios, '12.4'
```

The plugin requests camera and microphone access, make sure to include the required entries for `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` in your `Info.plist` file from the `ios/Runner` directory.

```plist
<key>NSCameraUsageDescription</key>
<string>The app needs access to your camera for meetings.</string>
<key>NSMicrophoneUsageDescription</key>
<string>The app needs access to your microphone for meetings.</string>
```

### Android

Go to `android/app/build.gradle` and make sure that the `minSdkVersion` is set to `at lest 24`

```
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 24
    }
}
```


The `application:label` field from the Jitsi Meet Android SDK will conflict with your application's one . Go to `android/app/src/main/AndroidManifest.xml` and add the tools library and `tools:replace="android:label"` to the application tag.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android" 
    xmlns:tools="http://schemas.android.com/tools">
    <application
        tools:replace="android:label"
        android:label="sample_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        ...
    </application>
</manifest>
```





