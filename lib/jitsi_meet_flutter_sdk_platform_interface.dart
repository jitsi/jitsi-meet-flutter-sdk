import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jitsi_meet_flutter_sdk_method_channel.dart';
import 'method_response.dart';

abstract class JitsiMeetFlutterSdkPlatform extends PlatformInterface {
  /// Constructs a JitsiMeetFlutterSdkPlatform.
  JitsiMeetFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static JitsiMeetFlutterSdkPlatform _instance = MethodChannelJitsiMeetFlutterSdk();

  /// The default instance of [JitsiMeetFlutterSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelJitsiMeetFlutterSdk].
  static JitsiMeetFlutterSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JitsiMeetFlutterSdkPlatform] when
  /// they register themselves.
  static set instance(JitsiMeetFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<MethodResponse> join() {
    throw UnimplementedError('join() has not been implemented.');
  }
}
