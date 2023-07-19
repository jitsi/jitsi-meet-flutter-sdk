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
      conferenceJoined: (url) {
        debugPrint("conferenceJoined: url: $url");
      },

      conferenceTerminated: (url, error) {
        debugPrint("conferenceTerminated: url: $url, error: $error");
      },

      conferenceWillJoin: (url) {
        debugPrint("conferenceWillJoin: url: $url");
      },

      participantJoined: (email, name, role, participantId) {
        debugPrint(
          "participantJoined: email: $email, name: $name, role: $role, "
              "participantId: $participantId",
        );
      },

      participantLeft: (participantId) {
        debugPrint("participantLeft: participantId: $participantId");
      },

      audioMutedChanged: (isMuted) {
        debugPrint("audioMutedChanged: isMuted: $isMuted");
      },

      videoMutedChanged: (isMuted) {
        debugPrint("videoMutedChanged: isMuted: $isMuted");
      },

      endpointTextMessageReceived: (senderId, message) {
        debugPrint(
            "endpointTextMessageReceived: senderId: $senderId, message: $message"
        );
      },

      screenShareToggled: (participantId, isSharing) {
        debugPrint(
          "screenShareToggled: participantId: $participantId, "
              "isSharing: $isSharing",
        );
      },

      chatMessageReceived: (senderId, message, isPrivate) {
        debugPrint(
          "chatMessageReceived: senderId: $senderId, message: $message, "
              "isPrivate: $isPrivate",
        );
      },

      chatToggled: (isOpen) => debugPrint("chatToggled: isOpen: $isOpen"),

      participantsInfoRetrieved: (participantsInfo, requestId) {
        debugPrint(
          "participantsInfoRetrieved: participantsInfo: $participantsInfo, "
              "requestId: $requestId",
        );
      },

      readyToClose: () {
        debugPrint("readyToClose");
      },
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
