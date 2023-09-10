import 'package:flutter/material.dart';

import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

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

  join() async {
    var options = JitsiMeetConferenceOptions(
      room: "UselessPeppersSentenceTypically",
      configOverrides: {
        "startWithAudioMuted": true,
        "startWithVideoMuted": true,
      },
      featureFlags: {
        FeaturesFlag.addPeopleEnabled: true,
        FeaturesFlag.welcomePageEnabled: true,
        FeaturesFlag.preJoinPageEnabled: true,
        FeaturesFlag.unsafeRoomWarningEnabled: true,
        FeaturesFlag.resolution: FeaturesFlagVideoResolution.resolution720p,
        FeaturesFlag.audioFocusDisabled: true,
        FeaturesFlag.audioMuteButtonEnabled: true,
        FeaturesFlag.audioOnlyButtonEnabled: true,
        FeaturesFlag.calenderEnabled: true,
        FeaturesFlag.callIntegrationEnabled: true,
        FeaturesFlag.carModeEnabled: true,
        FeaturesFlag.closeCaptionsEnabled: true,
        FeaturesFlag.conferenceTimerEnabled: true,
        FeaturesFlag.chatEnabled: true,
        FeaturesFlag.filmstripEnabled: true,
        FeaturesFlag.fullScreenEnabled: true,
        FeaturesFlag.helpButtonEnabled: true,
        FeaturesFlag.inviteEnabled: true,
        FeaturesFlag.androidScreenSharingEnabled: true,
        FeaturesFlag.speakerStatsEnabled: true,
        FeaturesFlag.kickOutEnabled: true,
        FeaturesFlag.liveStreamingEnabled: true,
        FeaturesFlag.lobbyModeEnabled: true,
        FeaturesFlag.meetingNameEnabled: true,
        FeaturesFlag.meetingPasswordEnabled: true,
        FeaturesFlag.notificationEnabled: true,
        FeaturesFlag.overflowMenuEnabled: true,
        FeaturesFlag.pipEnabled: true,
        FeaturesFlag.pipWhileScreenSharingEnabled: true,
        FeaturesFlag.preJoinPageHideDisplayName: true,
        FeaturesFlag.raiseHandEnabled: true,
        FeaturesFlag.reactionsEnabled: true,
        FeaturesFlag.recordingEnabled: true,
        FeaturesFlag.replaceParticipant: true,
        FeaturesFlag.securityOptionEnabled: true,
        FeaturesFlag.serverUrlChangeEnabled: true,
        FeaturesFlag.settingsEnabled: true,
        FeaturesFlag.tileViewEnabled: true,
        FeaturesFlag.videoMuteEnabled: true,
        FeaturesFlag.videoShareEnabled: true,
        FeaturesFlag.toolboxEnabled: true,
        FeaturesFlag.iosRecordingEnabled: true,
        FeaturesFlag.iosScreenSharingEnabled: true,
        FeaturesFlag.toolboxAlwaysVisible: true,
      },
      userInfo: JitsiMeetUserInfo(
          displayName: "Gabi",
          email: "gabi.borlea.1@gmail.com",
          avatar:
              "https://avatars.githubusercontent.com/u/57035818?s=400&u=02572f10fe61bca6fc20426548f3920d53f79693&v=4"),
    );

    var listener = JitsiMeetEventListener(
      conferenceJoined: (url) {
        print("conferenceJoined: url: $url");
        retrieveParticipantsInfo();
      },
      conferenceTerminated: (url, error) {
        print("conferenceTerminated: url: $url, error: $error");
      },
      conferenceWillJoin: (url) {
        print("conferenceWillJoin: url: $url");
      },
      participantJoined: (email, name, role, participantId) {
        print(
          "participantJoined: email: $email, name: $name, role: $role, "
          "participantId: $participantId",
        );
        participants.add(participantId!);
      },
      participantLeft: (participantId) {
        print("participantLeft: participantId: $participantId");
      },
      audioMutedChanged: (muted) {
        print("audioMutedChanged: isMuted: $muted");
      },
      videoMutedChanged: (muted) {
        print("videoMutedChanged: isMuted: $muted");
      },
      endpointTextMessageReceived: (senderId, message) {
        print(
            "endpointTextMessageReceived: senderId: $senderId, message: $message");
      },
      screenShareToggled: (participantId, sharing) {
        print(
          "screenShareToggled: participantId: $participantId, "
          "isSharing: $sharing",
        );
      },
      chatMessageReceived: (senderId, message, isPrivate, timestamp) {
        print(
          "chatMessageReceived: senderId: $senderId, message: $message, "
          "isPrivate: $isPrivate, timestamp: $timestamp",
        );
      },
      chatToggled: (isOpen) => print("chatToggled: isOpen: $isOpen"),
      participantsInfoRetrieved: (participantsInfo) {
        print(
            "participantsInfoRetrieved: participantsInfo: $participantsInfo, ");
      },
      readyToClose: () {
        print("readyToClose");
      },
    );
    await _jitsiMeetPlugin.join(options, listener);
  }

  hangUp() async {
    await _jitsiMeetPlugin.hangUp();
  }

  setAudioMuted(bool? muted) async {
    var a = await _jitsiMeetPlugin.setAudioMuted(muted!);
    print("$a");
    setState(() {
      audioMuted = muted;
    });
  }

  setVideoMuted(bool? muted) async {
    var a = await _jitsiMeetPlugin.setVideoMuted(muted!);
    print("$a");
    setState(() {
      videoMuted = muted;
    });
  }

  sendEndpointTextMessage() async {
    var a = await _jitsiMeetPlugin.sendEndpointTextMessage(message: "HEY");
    print("$a");

    for (var p in participants) {
      var b =
          await _jitsiMeetPlugin.sendEndpointTextMessage(to: p, message: "HEY");
      print("$b");
    }
  }

  toggleScreenShare(bool? enabled) async {
    await _jitsiMeetPlugin.toggleScreenShare(enabled!);

    setState(() {
      screenShareOn = enabled;
    });
  }

  openChat() async {
    await _jitsiMeetPlugin.openChat();
  }

  sendChatMessage() async {
    var a = await _jitsiMeetPlugin.sendChatMessage(message: "HEY1");
    print("$a");

    for (var p in participants) {
      a = await _jitsiMeetPlugin.sendChatMessage(to: p, message: "HEY2");
      print("$a");
    }
  }

  closeChat() async {
    await _jitsiMeetPlugin.closeChat();
  }

  retrieveParticipantsInfo() async {
    var a = await _jitsiMeetPlugin.retrieveParticipantsInfo();
    print("$a");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton(
                    onPressed: join,
                    child: const Text("Join"),
                  ),
                  TextButton(onPressed: hangUp, child: const Text("Hang Up")),
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
                      child: const Text("Send Hey Endpoint Message To All")),
                  Row(children: [
                    const Text("Toggle Screen Share"),
                    Checkbox(
                      value: screenShareOn,
                      onChanged: toggleScreenShare,
                    ),
                  ]),
                  TextButton(
                      onPressed: openChat, child: const Text("Open Chat")),
                  TextButton(
                      onPressed: sendChatMessage,
                      child: const Text("Send Chat Message to All")),
                  TextButton(
                      onPressed: closeChat, child: const Text("Close Chat")),
                  TextButton(
                      onPressed: retrieveParticipantsInfo,
                      child: const Text("Retrieve Participants Info")),
                ]),
          )),
    );
  }
}
