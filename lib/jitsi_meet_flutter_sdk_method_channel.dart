import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'jitsi_meet_flutter_sdk_platform_interface.dart';

/// An implementation of [JitsiMeetFlutterSdkPlatform] that uses method channels.
class MethodChannelJitsiMeetFlutterSdk extends JitsiMeetFlutterSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('jitsi_meet_flutter_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> join() async {
    await methodChannel.invokeListMethod('join');
  }
}
