import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'jitsi_meet_method_channel.dart';
import 'jitsi_meet_event_listener.dart';
import 'jitsi_meet_conference_options.dart';
import 'method_response.dart';

abstract class JitsiMeetPlatform extends PlatformInterface {
  /// Constructs a JitsiMeetPlatform.
  JitsiMeetPlatform() : super(token: _token);

  static final Object _token = Object();

  static JitsiMeetPlatform _instance = MethodChannelJitsiMeet();

  /// The default instance of [JitsiMeetPlatform] to use.
  ///
  /// Defaults to [MethodChannelJitsiMeet].
  static JitsiMeetPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JitsiMeetPlatform] when
  /// they register themselves.
  static set instance(JitsiMeetPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Joins a meeting with the given meeting [options] and
  /// optionally a [listener] is given for listening to events triggered by the native sdks.
  Future<MethodResponse> join(
      JitsiMeetConferenceOptions options, JitsiMeetEventListener? listener) {
    throw UnimplementedError('join() has not been implemented.');
  }

  /// The localParticipant leaves the current meeting.
  Future<MethodResponse> hangUp() {
    throw UnimplementedError('hangUp() has not been implemented.');
  }

  /// Sets the state of the localParticipant audio [muted] according to the muted parameter.
  Future<MethodResponse> setAudioMuted(bool muted) {
    throw UnimplementedError('setAudioMuted() has not been implemented.');
  }

  /// Sets the state of the localParticipant video [muted] according to the muted parameter.
  Future<MethodResponse> setVideoMuted(bool muted) {
    throw UnimplementedError('setVideoMuted() has not been implemented.');
  }

  /// Sends a message via the data channel [to] one particular participant or to all of them.
  /// If the [to] param is empty, the [message] will be sent to all the participants in the conference.
  ///
  /// In order to get the participantId for the [to] parameter, the [JitsiMeetEventListener.participantsJoined]
  /// event should be listened for, which have as a parameter the participantId and this should be stored somehow.
  Future<MethodResponse> sendEndpointTextMessage(
      {String? to, required String message}) async {
    throw UnimplementedError(
        'sendEndpointTextMessage() has not been implemented.');
  }

  /// Sets the state of the localParticipant screen sharing according to the [enabled] parameter.
  Future<MethodResponse> toggleScreenShare(bool enabled) async {
    throw UnimplementedError(
        'sendEndpointTextMessage() has not been implemented.');
  }

  /// Opens the chat dialog. If [to] contains a valid participantId, the private chat with that
  /// particular participant will be opened.
  Future<MethodResponse> openChat([String? to]) async {
    throw UnimplementedError('openChat() has not been implemented.');
  }

  /// Sends a chat message via [to] one particular participant or to all of them.
  /// If the [to] param is empty, the [message] will be sent to all the participants in the conference.
  ///
  /// In order to get the participantId for the [to] parameter, the [JitsiMeetEventListener.participantsJoined]
  /// event should be listened for, which have as a parameter the participantId and this should be stored somehow.
  Future<MethodResponse> sendChatMessage(
      {String? to, required String message}) async {
    throw UnimplementedError('sendChatMessage() has not been implemented.');
  }

  /// Closes the chat dialog.
  Future<MethodResponse> closeChat() async {
    throw UnimplementedError('openChat() has not been implemented.');
  }

  /// Sends and event that will trigger the [JitsiMeetEventListener.participantsInfoRetrieved] event
  /// which will contain participants information.
  Future<MethodResponse> retrieveParticipantsInfo() async {
    throw UnimplementedError(
        'retrieveParticipantsInfo() has not been implemented.');
  }
}
