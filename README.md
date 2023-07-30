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
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_conference_options.dart';
```

### Usage

#### Join meeting

Firstly, create a `JitsiMeetFlutterSdk` object, then call the method join from it with a `JitsiMeetConferenceOptions` object

```dart
    var jitsiMeet = JitsiMeetFlutterSdk();
    var options = JitsiMeetConferenceOptions(room: 'jitsiIsAwesome');
    jitsiMeet.join(options);
```

## Configuration

### 

### iOS

Make sure in `Podfile` from `ios` directory you set the ios version `12.4 or higher` 

The plugin requests camera and microphone access, make sure to include the required entries for `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` in your `Info.plist` file from the `ios/Runner` directory.

```plist
<key>NSCameraUsageDescription</key>
<string>The app needs access to your camera for meetings.</string>
<key>NSMicrophoneUsageDescription</key>
<string>The app needs access to your microphone for meetings.</string>
```




