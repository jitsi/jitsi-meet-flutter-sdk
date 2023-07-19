import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jitsi_meet_flutter_sdk/method_response.dart';

import 'jitsi_meet_flutter_sdk_platform_interface.dart';
import 'jitsi_meet_listener.dart';
import 'jitsi_meet_options.dart';

/// An implementation of [JitsiMeetFlutterSdkPlatform] that uses method channels.
class MethodChannelJitsiMeetFlutterSdk extends JitsiMeetFlutterSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('jitsi_meet_flutter_sdk');
  @visibleForTesting
  final eventChannel = const EventChannel('jitsi_meet_flutter_sdk_events');

  bool _eventChannelIsInitialized = false;
  JitsiMeetListener? _listener;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<MethodResponse> join(JitsiMeetOptions options, JitsiMeetListener? listener) async {
    _listener = listener;
    if (!_eventChannelIsInitialized) {
      _initialize();
    }
    return await methodChannel
        .invokeMethod<String>('join')
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
        case "opened":
          _listener?.onOpened?.call();
          break;
        case "readyToClose":
          _listener?.onReadyToClose?.call();
          break;
        case "conferenceWillJoin":
          _listener?.onConferenceWillJoin?.call(data["url"]);
          break;
        case "conferenceJoined":
          _listener?.onConferenceJoined?.call(data["url"]);
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
