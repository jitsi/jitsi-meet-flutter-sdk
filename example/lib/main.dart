import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_listener.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _jitsiMeetFlutterSdkPlugin = JitsiMeetFlutterSdk();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _jitsiMeetFlutterSdkPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  join() async{
    var options = JitsiMeetOptions(
      room: "testgabigabi",
      serverUrl: "https://meet.jit.si"
    );
    var listener = JitsiMeetListener(
      onOpened: () => debugPrint("onOpened"),
      onReadyToClose: () {
        debugPrint("onReadyToClose");
      },
      onConferenceWillJoin: (url) {
        debugPrint("onConferenceWillJoin: url: $url");
      },
      onConferenceJoined: (url) {
        debugPrint("onConferenceJoined: url: $url");
      },
      onConferenceTerminated: (url, error) {
        debugPrint("onConferenceTerminated: url: $url, error: $error");
      },
      onAudioMutedChanged: (isMuted) {
        debugPrint("onAudioMutedChanged: isMuted: $isMuted");
      },
      onVideoMutedChanged: (isMuted) {
        debugPrint("onVideoMutedChanged: isMuted: $isMuted");
      },
      onScreenShareToggled: (participantId, isSharing) {
        debugPrint(
          "onScreenShareToggled: participantId: $participantId, "
              "isSharing: $isSharing",
        );
      },
      onParticipantJoined: (email, name, role, participantId) {
        debugPrint(
          "onParticipantJoined: email: $email, name: $name, role: $role, "
              "participantId: $participantId",
        );
      },
      onParticipantLeft: (participantId) {
        debugPrint("onParticipantLeft: participantId: $participantId");
      },
      onParticipantsInfoRetrieved: (participantsInfo, requestId) {
        debugPrint(
          "onParticipantsInfoRetrieved: participantsInfo: $participantsInfo, "
              "requestId: $requestId",
        );
      },
      onChatMessageReceived: (senderId, message, isPrivate) {
        debugPrint(
          "onChatMessageReceived: senderId: $senderId, message: $message, "
              "isPrivate: $isPrivate",
        );
      },
      onChatToggled: (isOpen) => debugPrint("onChatToggled: isOpen: $isOpen"),
      onClosed: () => debugPrint("onClosed"),
    );
    await _jitsiMeetFlutterSdkPlugin.join(options, listener);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: TextButton(onPressed: join, child: const Text('Join Meeting')),
        ),
      ),
    );
  }
}
