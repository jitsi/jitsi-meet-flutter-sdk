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
  // When built with --dart-define=E2EE_AUTOJOIN=1 the app joins the room
  // automatically with E2EE enabled and no prejoin page (used for headless
  // simulator/device testing).
  static const bool _autoJoin = bool.fromEnvironment('E2EE_AUTOJOIN');
  bool audioMuted = true;
  bool videoMuted = true;
  bool screenShareOn = false;
  bool e2eeEnabled = false;
  List<String> participants = [];
  final _jitsiMeetPlugin = JitsiMeet();
  final TextEditingController _roomController =
      TextEditingController(text: "e2ee-test-room");
  final TextEditingController _e2eeKeyController =
      TextEditingController(text: "correct horse battery staple");

  @override
  void initState() {
    super.initState();
    if (_autoJoin) {
      e2eeEnabled = true;
      Future.delayed(const Duration(seconds: 3), join);
    }
  }

  join() async {
    var options = JitsiMeetConferenceOptions(
      serverURL: "https://meet.ffmuc.net",
      room: _roomController.text,
      e2eeEnabled: e2eeEnabled,
      e2eeKey: e2eeEnabled ? _e2eeKeyController.text : null,
      configOverrides: {
        "startWithAudioMuted": true,
        "startWithVideoMuted": true,
      },
      featureFlags: {
        FeatureFlags.addPeopleEnabled: true,
        FeatureFlags.welcomePageEnabled: !_autoJoin,
        FeatureFlags.preJoinPageEnabled: !_autoJoin,
        FeatureFlags.unsafeRoomWarningEnabled: true,
        FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution720p,
        FeatureFlags.audioFocusDisabled: true,
        FeatureFlags.audioMuteButtonEnabled: true,
        FeatureFlags.audioOnlyButtonEnabled: true,
        FeatureFlags.calenderEnabled: true,
        FeatureFlags.callIntegrationEnabled: true,
        FeatureFlags.carModeEnabled: true,
        FeatureFlags.closeCaptionsEnabled: true,
        FeatureFlags.conferenceTimerEnabled: true,
        FeatureFlags.chatEnabled: true,
        FeatureFlags.filmstripEnabled: true,
        FeatureFlags.fullScreenEnabled: true,
        FeatureFlags.helpButtonEnabled: true,
        FeatureFlags.inviteEnabled: true,
        FeatureFlags.androidScreenSharingEnabled: true,
        FeatureFlags.speakerStatsEnabled: true,
        FeatureFlags.kickOutEnabled: true,
        FeatureFlags.liveStreamingEnabled: true,
        FeatureFlags.lobbyModeEnabled: true,
        FeatureFlags.meetingNameEnabled: true,
        FeatureFlags.meetingPasswordEnabled: true,
        FeatureFlags.notificationEnabled: true,
        FeatureFlags.overflowMenuEnabled: true,
        FeatureFlags.pipEnabled: true,
        FeatureFlags.pipWhileScreenSharingEnabled: true,
        FeatureFlags.preJoinPageHideDisplayName: true,
        FeatureFlags.raiseHandEnabled: true,
        FeatureFlags.reactionsEnabled: true,
        FeatureFlags.recordingEnabled: true,
        FeatureFlags.replaceParticipant: true,
        FeatureFlags.securityOptionEnabled: true,
        FeatureFlags.serverUrlChangeEnabled: true,
        FeatureFlags.settingsEnabled: true,
        FeatureFlags.tileViewEnabled: true,
        FeatureFlags.videoMuteEnabled: true,
        FeatureFlags.videoShareEnabled: true,
        FeatureFlags.toolboxEnabled: true,
        FeatureFlags.iosRecordingEnabled: true,
        FeatureFlags.iosScreenSharingEnabled: true,
        FeatureFlags.toolboxAlwaysVisible: true,
      },
      userInfo: JitsiMeetUserInfo(
          displayName: "Gabi",
          email: "gabi.borlea.1@gmail.com",
          avatar:
              "https://avatars.githubusercontent.com/u/57035818?s=400&u=02572f10fe61bca6fc20426548f3920d53f79693&v=4"),
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
      audioMutedChanged: (muted) {
        debugPrint("audioMutedChanged: isMuted: $muted");
      },
      videoMutedChanged: (muted) {
        debugPrint("videoMutedChanged: isMuted: $muted");
      },
      endpointTextMessageReceived: (senderId, message) {
        debugPrint(
            "endpointTextMessageReceived: senderId: $senderId, message: $message");
      },
      screenShareToggled: (participantId, sharing) {
        debugPrint(
          "screenShareToggled: participantId: $participantId, "
          "isSharing: $sharing",
        );
      },
      chatMessageReceived: (senderId, message, isPrivate, timestamp) {
        debugPrint(
          "chatMessageReceived: senderId: $senderId, message: $message, "
          "isPrivate: $isPrivate, timestamp: $timestamp",
        );
      },
      chatToggled: (isOpen) => debugPrint("chatToggled: isOpen: $isOpen"),
      participantsInfoRetrieved: (participantsInfo) {
        debugPrint(
            "participantsInfoRetrieved: participantsInfo: $participantsInfo, ");
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

  setAudioMuted(bool? muted) async {
    var a = await _jitsiMeetPlugin.setAudioMuted(muted!);
    debugPrint("$a");
    setState(() {
      audioMuted = muted;
    });
  }

  setVideoMuted(bool? muted) async {
    var a = await _jitsiMeetPlugin.setVideoMuted(muted!);
    debugPrint("$a");
    setState(() {
      videoMuted = muted;
    });
  }

  sendEndpointTextMessage() async {
    var a = await _jitsiMeetPlugin.sendEndpointTextMessage(message: "HEY");
    debugPrint("$a");

    for (var p in participants) {
      var b =
          await _jitsiMeetPlugin.sendEndpointTextMessage(to: p, message: "HEY");
      debugPrint("$b");
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
    debugPrint("$a");

    for (var p in participants) {
      a = await _jitsiMeetPlugin.sendChatMessage(to: p, message: "HEY2");
      debugPrint("$a");
    }
  }

  closeChat() async {
    await _jitsiMeetPlugin.closeChat();
  }

  retrieveParticipantsInfo() async {
    var a = await _jitsiMeetPlugin.retrieveParticipantsInfo();
    debugPrint("$a");
  }

  toggleE2EE(bool? enabled) async {
    setState(() {
      e2eeEnabled = enabled ?? false;
    });
    var a = await _jitsiMeetPlugin.setE2EEEnabled(e2eeEnabled);
    debugPrint("setE2EEEnabled: $a");
  }

  rotateE2EEKey() async {
    final newKey = _e2eeKeyController.text;
    var a = await _jitsiMeetPlugin.setE2EEKey(newKey);
    debugPrint("setE2EEKey: $a");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Jitsi E2EE test app'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextField(
                      controller: _roomController,
                      decoration: const InputDecoration(labelText: "Room"),
                    ),
                    TextField(
                      controller: _e2eeKeyController,
                      decoration:
                          const InputDecoration(labelText: "E2EE shared key"),
                    ),
                    Row(children: [
                      const Text("E2EE enabled"),
                      Checkbox(
                        value: e2eeEnabled,
                        onChanged: (v) =>
                            setState(() => e2eeEnabled = v ?? false),
                      ),
                    ]),
                    TextButton(
                      onPressed: join,
                      child: const Text("Join"),
                    ),
                    TextButton(onPressed: hangUp, child: const Text("Hang Up")),
                    TextButton(
                        onPressed: rotateE2EEKey,
                        child: const Text("Apply E2EE Key (mid-call)")),
                    TextButton(
                        onPressed: () => toggleE2EE(!e2eeEnabled),
                        child: const Text("Toggle E2EE (mid-call)")),
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
                  ]),
            ),
          )),
    );
  }
}
