import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_event_listener.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_conference_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _jitsiMeetFlutterSdkPlugin = JitsiMeetFlutterSdk();

  join() async{
    var options = JitsiMeetConferenceOptions(
      room: ""
    );

    var listener = JitsiMeetEventListener(
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
