import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jitsi_meet_flutter_sdk/src/method_response.dart';

import 'jitsi_meet_conference_options.dart';
import 'jitsi_meet_event_listener.dart';
import 'jitsi_meet_platform_interface.dart';

/// An implementation of [JitsiMeetPlatform] that uses method channels.
class MethodChannelJitsiMeet extends JitsiMeetPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('jitsi_meet_flutter_sdk');
  @visibleForTesting
  final eventChannel = const EventChannel('jitsi_meet_flutter_sdk_events');

  bool _eventChannelIsInitialized = false;
  JitsiMeetEventListener? _listener;

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Joins a meeting with the given meeting [options] and
  /// optionally a [listener] is given for listening to events triggered by the native sdks.
  @override
  Future<MethodResponse> join(JitsiMeetConferenceOptions options,
      JitsiMeetEventListener? listener) async {
    _listener = listener;
    if (!_eventChannelIsInitialized) {
      _initialize();
    }

    Map<String, dynamic> parsedOptions = {
      'serverURL': options.serverURL,
      'room': options.room,
      'token': options.token,
      'userInfo': {
        'displayName': options.userInfo?.displayName,
        'email': options.userInfo?.email,
        'avatar': options.userInfo?.avatar,
      },
      'featureFlags': options.featureFlags,
      'configOverrides': options.configOverrides
    };
    return await methodChannel
        .invokeMethod<String>('join', parsedOptions)
        .then((message) {
      return MethodResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return MethodResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  /// The localParticipant leaves the current meeting.
  @override
  Future<MethodResponse> hangUp() async {
    return await methodChannel.invokeMethod<String>('hangUp').then((message) {
      return MethodResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return MethodResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  /// Sets the state of the localParticipant audio [muted] according to the muted parameter.
  @override
  Future<MethodResponse> setAudioMuted(bool muted) async {
    return await methodChannel.invokeMethod<String>(
        'setAudioMuted', {'muted': muted}).then((message) {
      return MethodResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return MethodResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  /// Sets the state of the localParticipant video [muted] according to the muted parameter.
  @override
  Future<MethodResponse> setVideoMuted(bool muted) async {
    return await methodChannel.invokeMethod<String>(
        'setVideoMuted', {'muted': muted}).then((message) {
      return MethodResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return MethodResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  /// Sends a message via the data channel [to] one particular participant or to all of them.
  /// If the [to] param is empty, the [message] will be sent to all the participants in the conference.
  ///
  /// In order to get the participantId for the [to] parameter, the [JitsiMeetEventListener.participantsJoined]
  /// event should be listened for, which have as a parameter the participantId and this should be stored somehow.
  @override
  Future<MethodResponse> sendEndpointTextMessage(
      {String? to, required String message}) async {
    return await methodChannel.invokeMethod<String>('sendEndpointTextMessage',
        {'to': to ?? '', 'message': message}).then((message) {
      return MethodResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return MethodResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  /// Sets the state of the localParticipant screen sharing according to the [enabled] parameter.
  @override
  Future<MethodResponse> toggleScreenShare(bool enabled) async {
    return await methodChannel.invokeMethod<String>(
        'toggleScreenShare', {'enabled': enabled}).then((message) {
      return MethodResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return MethodResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  /// Opens the chat dialog. If [to] contains a valid participantId, the private chat with that
  /// particular participant will be opened.
  @override
  Future<MethodResponse> openChat([String? to]) async {
    return await methodChannel.invokeMethod<String>('openChat', {
      'to': to ?? '',
    }).then((message) {
      return MethodResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return MethodResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  /// Sends a chat message via [to] one particular participant or to all of them.
  /// If the [to] param is empty, the [message] will be sent to all the participants in the conference.
  ///
  /// In order to get the participantId for the [to] parameter, the [JitsiMeetEventListener.participantsJoined]
  /// event should be listened for, which have as a parameter the participantId and this should be stored somehow.
  @override
  Future<MethodResponse> sendChatMessage(
      {String? to, required String message}) async {
    return await methodChannel.invokeMethod<String>('sendChatMessage',
        {'to': to ?? '', 'message': message}).then((message) {
      return MethodResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return MethodResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  /// Closes the chat dialog.
  @override
  Future<MethodResponse> closeChat() async {
    return await methodChannel
        .invokeMethod<String>('closeChat')
        .then((message) {
      return MethodResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return MethodResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  /// Sends and event that will trigger the [JitsiMeetEventListener.participantsInfoRetrieved] event
  /// which will contain participants information.
  @override
  Future<MethodResponse> retrieveParticipantsInfo() async {
    return await methodChannel
        .invokeMethod<String>('retrieveParticipantsInfo')
        .then((message) {
      return MethodResponse(isSuccess: true, message: message);
    }).catchError((error) {
      return MethodResponse(
        isSuccess: false,
        message: error.toString(),
        error: error,
      );
    });
  }

  void _initialize() {
    eventChannel.receiveBroadcastStream().listen((message) {
      final data = message['data'];
      switch (message['event']) {
        case "conferenceJoined":
          _listener?.conferenceJoined?.call(data["url"]);
          break;

        case "conferenceTerminated":
          _listener?.conferenceTerminated?.call(data["url"], data["error"]);
          break;

        case "conferenceWillJoin":
          _listener?.conferenceWillJoin?.call(data["url"]);
          break;

        case "participantJoined":
          _listener?.participantJoined?.call(
            data["email"],
            data["name"],
            data["role"],
            data["participantId"],
          );
          break;

        case "participantLeft":
          _listener?.participantLeft?.call(data["participantId"]);
          break;

        case "audioMutedChanged":
          _listener?.audioMutedChanged?.call(parseBool(data["muted"]));
          break;

        case "videoMutedChanged":
          _listener?.videoMutedChanged?.call(parseBool(data["muted"]));
          break;

        case "endpointTextMessageReceived":
          _listener?.endpointTextMessageReceived
              ?.call(data["senderId"], data["message"]);
          break;

        case "screenShareToggled":
          _listener?.screenShareToggled
              ?.call(data["participantId"], parseBool(data["sharing"]));
          break;

        case "chatMessageReceived":
          _listener?.chatMessageReceived?.call(
            data["senderId"],
            data["message"],
            parseBool(data["isPrivate"]),
            data["timestamp"],
          );
          break;

        case "chatToggled":
          _listener?.chatToggled?.call(parseBool(data["isOpen"]));
          break;

        case "participantsInfoRetrieved":
          String participantsInfo = "";
          if (Platform.isAndroid) {
            participantsInfo = data["participantsInfo"];
          } else if (Platform.isIOS) {
            participantsInfo = data.toString();
          }
          _listener?.participantsInfoRetrieved?.call(
            participantsInfo,
          );
          break;

        case "readyToClose":
          _listener?.readyToClose?.call();
          break;

        case "customOverflowMenuButtonPressed":
          _listener?.customOverflowMenuButtonPressed?.call(data["id"]);
          break;
      }
    }).onError((error) {
      debugPrint("Error receiving data from the event channel: $error");
    });
    _eventChannelIsInitialized = true;
  }
}

bool parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) return value == 'true';
  if (value is num) return value != 0;
  throw ArgumentError('Unsupported type: $value');
}
