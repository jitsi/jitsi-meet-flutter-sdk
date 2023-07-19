import 'package:flutter_test/flutter_test.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk_platform_interface.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk_method_channel.dart';
import 'package:jitsi_meet_flutter_sdk/method_response.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJitsiMeetFlutterSdkPlatform
    with MockPlatformInterfaceMixin
    implements JitsiMeetFlutterSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<MethodResponse> join() {
    // TODO: implement join
    throw UnimplementedError();
  }
}

void main() {
  final JitsiMeetFlutterSdkPlatform initialPlatform = JitsiMeetFlutterSdkPlatform.instance;

  test('$MethodChannelJitsiMeetFlutterSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelJitsiMeetFlutterSdk>());
  });

  test('getPlatformVersion', () async {
    JitsiMeetFlutterSdk jitsiMeetFlutterSdkPlugin = JitsiMeetFlutterSdk();
    MockJitsiMeetFlutterSdkPlatform fakePlatform = MockJitsiMeetFlutterSdkPlatform();
    JitsiMeetFlutterSdkPlatform.instance = fakePlatform;

    expect(await jitsiMeetFlutterSdkPlugin.getPlatformVersion(), '42');
  });
}
