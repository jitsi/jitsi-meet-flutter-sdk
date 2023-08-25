import 'jitsi_meet_platform_interface.dart';
import 'jitsi_meet_event_listener.dart';
import 'jitsi_meet_conference_options.dart';
import 'method_response.dart';

/// The entry point for the sdk. It is used to launch the meeting screen,
/// to send and receive all the events.
class JitsiMeet {
  Future<String?> getPlatformVersion() {
    return JitsiMeetPlatform.instance.getPlatformVersion();
  }

  /// Joins a meeting with the given meeting [options] and
  /// optionally a [listener] is given for listening to events triggered by the native sdks.
  Future<MethodResponse> join(JitsiMeetConferenceOptions options,
      [JitsiMeetEventListener? listener]) async {
    return await JitsiMeetPlatform.instance
        .join(options, listener ?? JitsiMeetEventListener());
  }

  /// The localParticipant leaves the current meeting.
  Future<MethodResponse> hangUp() async {
    return await JitsiMeetPlatform.instance.hangUp();
  }

  /// Sets the state of the localParticipant audio [muted] according to the muted parameter.
  Future<MethodResponse> setAudioMuted(bool muted) async {
    return await JitsiMeetPlatform.instance.setAudioMuted(muted);
  }

  /// Sets the state of the localParticipant video [muted] according to the muted parameter.
  Future<MethodResponse> setVideoMuted(bool muted) async {
    return await JitsiMeetPlatform.instance.setVideoMuted(muted);
  }

  /// Sends a message via the data channel [to] one particular participant or to all of them.
  /// If the [to] param is empty, the [message] will be sent to all the participants in the conference.
  ///
  /// In order to get the participantId for the [to] parameter, the [JitsiMeetEventListener.participantsJoined]
  /// event should be listened for, which have as a parameter the participantId and this should be stored somehow.
  Future<MethodResponse> sendEndpointTextMessage(
      {String? to, required String message}) async {
    return await JitsiMeetPlatform.instance
        .sendEndpointTextMessage(to: to, message: message);
  }

  /// Sets the state of the localParticipant screen sharing according to the [enabled] parameter.
  Future<MethodResponse> toggleScreenShare(bool enabled) async {
    return await JitsiMeetPlatform.instance.toggleScreenShare(enabled);
  }

  /// Opens the chat dialog. If [to] contains a valid participantId, the private chat with that
  /// particular participant will be opened.
  Future<MethodResponse> openChat([String? to]) async {
    return await JitsiMeetPlatform.instance.openChat(to);
  }

  /// Sends a chat message via [to] one particular participant or to all of them.
  /// If the [to] param is empty, the [message] will be sent to all the participants in the conference.
  ///
  /// In order to get the participantId for the [to] parameter, the [JitsiMeetEventListener.participantsJoined]
  /// event should be listened for, which have as a parameter the participantId and this should be stored somehow.
  Future<MethodResponse> sendChatMessage(
      {String? to, required String message}) async {
    return await JitsiMeetPlatform.instance
        .sendChatMessage(to: to, message: message);
  }

  /// Closes the chat dialog.
  Future<MethodResponse> closeChat() async {
    return await JitsiMeetPlatform.instance.closeChat();
  }

  /// Sends and event that will trigger the [JitsiMeetEventListener.participantsInfoRetrieved] event
  /// which will contain participants information.
  Future<MethodResponse> retrieveParticipantsInfo() async {
    return await JitsiMeetPlatform.instance.retrieveParticipantsInfo();
  }
}
