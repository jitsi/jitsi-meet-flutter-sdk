import 'jitsi_meet_flutter_sdk_platform_interface.dart';

import 'jitsi_meet_event_listener.dart';
import 'jitsi_meet_conference_options.dart';
import 'method_response.dart';

class JitsiMeetFlutterSdk {
  Future<String?> getPlatformVersion() {
    return JitsiMeetFlutterSdkPlatform.instance.getPlatformVersion();
  }

  Future<MethodResponse> join(JitsiMeetConferenceOptions options, [JitsiMeetEventListener? listener]) async{
    return await JitsiMeetFlutterSdkPlatform.instance.join(
        options,
        listener ?? JitsiMeetEventListener()
    );
  }

  Future<MethodResponse> hangUp() async{
    return await JitsiMeetFlutterSdkPlatform.instance.hangUp();
  }

  Future<MethodResponse> setAudioMuted({required bool muted}) async{
    return await JitsiMeetFlutterSdkPlatform.instance.setAudioMuted(muted: muted);
  }

  Future<MethodResponse> setVideoMuted({required bool muted}) async{
    return await JitsiMeetFlutterSdkPlatform.instance.setVideoMuted(muted: muted);
  }

  Future<MethodResponse> sendEndpointTextMessage({String? to, required String message}) async {
    return await JitsiMeetFlutterSdkPlatform.instance.sendEndpointTextMessage(to: to, message:message);
  }

  Future<MethodResponse> toggleScreenShare({required bool enabled}) async {
    return await JitsiMeetFlutterSdkPlatform.instance.toggleScreenShare(enabled: enabled);
  }

  Future<MethodResponse> openChat({String? to}) async {
    return await JitsiMeetFlutterSdkPlatform.instance.openChat(to: to);
  }

  Future<MethodResponse> sendChatMessage({String? to, required String message}) async {
    return await JitsiMeetFlutterSdkPlatform.instance.sendChatMessage(to: to, message:message);
  }

  Future<MethodResponse> closeChat() async {
    return await JitsiMeetFlutterSdkPlatform.instance.closeChat();
  }

  Future<MethodResponse> retrieveParticipantsInfo() async {
    return await JitsiMeetFlutterSdkPlatform.instance.retrieveParticipantsInfo();
  }
}
