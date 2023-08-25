import 'package:flutter_test/flutter_test.dart';
import 'package:jitsi_meet_flutter_sdk/src/jitsi_meet.dart';
import 'package:jitsi_meet_flutter_sdk/src/jitsi_meet_platform_interface.dart';
import 'package:jitsi_meet_flutter_sdk/src/jitsi_meet_method_channel.dart';
import 'package:jitsi_meet_flutter_sdk/src/jitsi_meet_event_listener.dart';
import 'package:jitsi_meet_flutter_sdk/src/jitsi_meet_conference_options.dart';
import 'package:jitsi_meet_flutter_sdk/src/method_response.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockJitsiMeetPlatform
    with MockPlatformInterfaceMixin
    implements JitsiMeetPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<MethodResponse> join(
      JitsiMeetConferenceOptions options, JitsiMeetEventListener? listener) {
    // TODO: implement join
    throw UnimplementedError();
  }

  @override
  Future<MethodResponse> hangUp() {
    // TODO: implement hangUp
    throw UnimplementedError();
  }

  @override
  Future<MethodResponse> setAudioMuted(bool muted) {
    // TODO: implement setAudioMuted
    throw UnimplementedError();
  }

  @override
  Future<MethodResponse> setVideoMuted(bool muted) {
    // TODO: implement setVideoMuted
    throw UnimplementedError();
  }

  @override
  Future<MethodResponse> sendEndpointTextMessage(
      {String? to, required String message}) {
    // TODO: implement sendEndpointTextMessage
    throw UnimplementedError();
  }

  @override
  Future<MethodResponse> toggleScreenShare(bool enabled) {
    // TODO: implement toggleScreenShare
    throw UnimplementedError();
  }

  @override
  Future<MethodResponse> openChat([String? to]) {
    // TODO: implement openChat
    throw UnimplementedError();
  }

  @override
  Future<MethodResponse> sendChatMessage(
      {String? to, required String message}) {
    // TODO: implement sendChatMessage
    throw UnimplementedError();
  }

  @override
  Future<MethodResponse> closeChat() {
    // TODO: implement closeChat
    throw UnimplementedError();
  }

  @override
  Future<MethodResponse> retrieveParticipantsInfo() {
    // TODO: implement retrieveParticipantsInfo
    throw UnimplementedError();
  }
}

void main() {
  final JitsiMeetPlatform initialPlatform = JitsiMeetPlatform.instance;

  test('$MethodChannelJitsiMeet is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelJitsiMeet>());
  });

  test('getPlatformVersion', () async {
    JitsiMeet jitsiMeetPlugin = JitsiMeet();
    MockJitsiMeetPlatform fakePlatform = MockJitsiMeetPlatform();
    JitsiMeetPlatform.instance = fakePlatform;

    expect(await jitsiMeetPlugin.getPlatformVersion(), '42');
  });
}
