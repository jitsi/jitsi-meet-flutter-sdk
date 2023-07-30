
import 'package:flutter/material.dart';

import 'package:jitsi_meet_flutter_sdk/jitsi_meet.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_event_listener.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_conference_options.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_user_info.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool audioMuted = true;
  bool videoMuted = true;
  bool screenShareOn = false;
  List<String> participants = [];
  final _jitsiMeetPlugin = JitsiMeet();

  join() async{
    var options = JitsiMeetConferenceOptions(
      room: "testgabigabi",
      configOverrides: {
        "startWithAudioMuted": false,
        "startWithVideoMuted": false,
        "subject" : "Lipitori"
      },
      featureFlags: {
        "unsaferoomwarning.enabled": false,
        "ios.screensharing.enabled": true
      },
      userInfo: JitsiMeetUserInfo(
          displayName: "Gabi",
          email: "gabi.borlea.1@gmail.com",
          avatar: "https://avatars.githubusercontent.com/u/57035818?s=400&u=02572f10fe61bca6fc20426548f3920d53f79693&v=4"
      ),
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
        participants.add(participantId!);
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

      participantsInfoRetrieved: (participantsInfo) {
        debugPrint(
          "participantsInfoRetrieved: participantsInfo: $participantsInfo, "
        );
      },

      readyToClose: () {
        debugPrint("readyToClose");
      },
    );
    await _jitsiMeetPlugin.join(options, listener);
  }

  hangUp() async {
    await _jitsiMeetPlugin.hangUp();
  }
  
  setAudioMuted(bool? muted) async{
    var a = await _jitsiMeetPlugin.setAudioMuted(muted: muted!);
    debugPrint("$a");
    setState(() {
      audioMuted = muted;
    });
  }

  setVideoMuted(bool? muted) async{
    var a = await _jitsiMeetPlugin.setVideoMuted(muted: muted!);
    debugPrint("$a");
    setState(() {
      videoMuted = muted;
    });
  }

  sendEndpointTextMessage() async{
    var a = await _jitsiMeetPlugin.sendEndpointTextMessage(message: "HEY");
    debugPrint("$a");

    for (var p in participants) {
      var b = await _jitsiMeetPlugin.sendEndpointTextMessage(to: p, message: "HEY");
      debugPrint("$b");
    }
  }

  toggleScreenShare(bool? enabled) async{
    await _jitsiMeetPlugin.toggleScreenShare(enabled: enabled!);

    setState(() {
      screenShareOn = enabled;
    });
  }

  openChat() async{
    await _jitsiMeetPlugin.openChat();
  }

  sendChatMessage() async{
    var a = await _jitsiMeetPlugin.sendChatMessage(to: null, message: "HEY1");
    debugPrint("$a");

    for (var p in participants) {
      a = await _jitsiMeetPlugin.sendChatMessage(to: p, message: "HEY2");
      debugPrint("$a");
    }
  }

  closeChat() async{
    await _jitsiMeetPlugin.closeChat();
  }

  retrieveParticipantsInfo() async{
    var a = await _jitsiMeetPlugin.retrieveParticipantsInfo();
    debugPrint("$a");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[

              TextButton(
                onPressed: join,
                child: const Text("Join"),
              ),
              TextButton(
                onPressed: hangUp,
                child: const Text("Hang Up")
              ),
              Row(children: [
                const Text("Set Audio Muted"),
                Checkbox(
                  value: audioMuted,
                  onChanged: setAudioMuted,
                ),
              ]),
              Row(children: [
                const Text("Set Video Muted"),
                Checkbox(
                  value: videoMuted,
                  onChanged: setVideoMuted,
                ),
              ]),
              TextButton(
                  onPressed: sendEndpointTextMessage,
                  child: const Text("Send Hey Endpoint Message To All")
              ),
              Row(children: [
                const Text("Toggle Screen Share"),
                Checkbox(
                  value: screenShareOn,
                  onChanged: toggleScreenShare,
                ),
              ]),
              TextButton(
                  onPressed: openChat,
                  child: const Text("Open Chat")
              ),
              TextButton(
                  onPressed: sendChatMessage,
                  child: const Text("Send Chat Message to All")
              ),
              TextButton(
                  onPressed: closeChat,
                  child: const Text("Close Chat")
              ),

              TextButton(
                  onPressed: retrieveParticipantsInfo,
                  child: const Text("Retrieve Participants Info")
              ),
            ]),
      )),
    );
  }
}
