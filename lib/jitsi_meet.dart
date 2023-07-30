import 'jitsi_meet_platform_interface.dart';

import 'jitsi_meet_event_listener.dart';
import 'jitsi_meet_conference_options.dart';
import 'method_response.dart';

class JitsiMeet {
  Future<String?> getPlatformVersion() {
    return JitsiMeetPlatform.instance.getPlatformVersion();
  }

  Future<MethodResponse> join(JitsiMeetConferenceOptions options, [JitsiMeetEventListener? listener]) async{
    return await JitsiMeetPlatform.instance.join(
        options,
        listener ?? JitsiMeetEventListener()
    );
  }

  Future<MethodResponse> hangUp() async{
    return await JitsiMeetPlatform.instance.hangUp();
  }

  Future<MethodResponse> setAudioMuted({required bool muted}) async{
    return await JitsiMeetPlatform.instance.setAudioMuted(muted: muted);
  }

  Future<MethodResponse> setVideoMuted({required bool muted}) async{
    return await JitsiMeetPlatform.instance.setVideoMuted(muted: muted);
  }

  Future<MethodResponse> sendEndpointTextMessage({String? to, required String message}) async {
    return await JitsiMeetPlatform.instance.sendEndpointTextMessage(to: to, message:message);
  }

  Future<MethodResponse> toggleScreenShare({required bool enabled}) async {
    return await JitsiMeetPlatform.instance.toggleScreenShare(enabled: enabled);
  }

  Future<MethodResponse> openChat({String? to}) async {
    return await JitsiMeetPlatform.instance.openChat(to: to);
  }

  Future<MethodResponse> sendChatMessage({String? to, required String message}) async {
    return await JitsiMeetPlatform.instance.sendChatMessage(to: to, message:message);
  }

  Future<MethodResponse> closeChat() async {
    return await JitsiMeetPlatform.instance.closeChat();
  }

  Future<MethodResponse> retrieveParticipantsInfo() async {
    return await JitsiMeetPlatform.instance.retrieveParticipantsInfo();
  }
}
