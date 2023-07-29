import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jitsi_meet_flutter_sdk/method_response.dart';

import 'jitsi_meet_flutter_sdk_platform_interface.dart';
import 'jitsi_meet_event_listener.dart';
import 'jitsi_meet_conference_options.dart';

/// An implementation of [JitsiMeetFlutterSdkPlatform] that uses method channels.
class MethodChannelJitsiMeetFlutterSdk extends JitsiMeetFlutterSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('jitsi_meet_flutter_sdk');
  @visibleForTesting
  final eventChannel = const EventChannel('jitsi_meet_flutter_sdk_events');

  bool _eventChannelIsInitialized = false;
  JitsiMeetEventListener? _listener;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<MethodResponse> join(JitsiMeetConferenceOptions options, JitsiMeetEventListener? listener) async {
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

  @override
  Future<MethodResponse> hangUp() async {
    return await methodChannel
        .invokeMethod<String>('hangUp')
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

  @override
  Future<MethodResponse> setAudioMuted({required bool muted}) async {
    return await methodChannel
        .invokeMethod<String>('setAudioMuted', {'muted': muted})
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

  @override
  Future<MethodResponse> setVideoMuted({required bool muted}) async {
    return await methodChannel
        .invokeMethod<String>('setVideoMuted', {'muted': muted})
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

  @override
  Future<MethodResponse> sendEndpointTextMessage({String? to, required String message}) async {
    return await methodChannel.invokeMethod<String>('sendEndpointTextMessage', {
          'to': to,
          'message': message
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

  @override
  Future<MethodResponse> toggleScreenShare({required bool enabled}) async {
    return await methodChannel.invokeMethod<String>('toggleScreenShare', {
      'enabled': enabled
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

  @override
  Future<MethodResponse> openChat({String? to}) async {
    return await methodChannel.invokeMethod<String>('openChat', {
      'to': to,
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

  @override
  Future<MethodResponse> sendChatMessage({String? to, required String message}) async {
    return await methodChannel.invokeMethod<String>('sendChatMessage', {
      'to': to,
      'message': message
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
          _listener?.endpointTextMessageReceived?.call(data["senderId"], data["message"]);
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
          );
          break;

        case "chatToggled":
          _listener?.chatToggled?.call(parseBool(data["isOpen"]));
          break;

        case "participantsInfoRetrieved":
          _listener?.participantsInfoRetrieved?.call(
            data["participantsInfo"],
          );
          break;

        case "readyToClose":
          _listener?.readyToClose?.call();
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
