class JitsiMeetListener {

  /// The native view got created.
  final Function()? onOpened;

  final Function()? onReadyToClose;

  // iOS: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk/#conferencewilljoin
  // Android: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk#conference_will_join
  final Function(String url)? onConferenceWillJoin;

  // iOS: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk/#conferencejoined
  // Android: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk#conference_joined
  final Function(String url)? onConferenceJoined;

  // iOS: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk/#conferenceterminated
  // Android: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk#conference_terminated
  final Function(String url, Object? error)? onConferenceTerminated;

  // iOS: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk/#audiomutedchanged
  // Android: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk#audio_muted_changed
  final Function(bool isMuted)? onAudioMutedChanged;

  // iOS: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk/#videomutedchanged
  // Android: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk#video_muted_changed
  final Function(bool isMuted)? onVideoMutedChanged;

  // iOS: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk#screensharetoggled
  // TODO(saibotma): Add Android docs when https://github.com/jitsi/handbook/pull/300 is merged.
  final Function(String participantId, bool isSharing)? onScreenShareToggled;

  // iOS: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk/#participantjoined
  // Android: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk#participant_joined
  final Function(
      String? email,
      String? name,
      String? role,
      String? participantId,
      )? onParticipantJoined;

  // iOS: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk/#participantleft
  // Android: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk#participant_left
  final Function(String? participantId)? onParticipantLeft;

  // Only for Android
  // https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk#participants_info_retrieved
  final Function(
      Map<String, dynamic> participantsInfo,
      String requestId,
      )? onParticipantsInfoRetrieved;

  // iOS: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk/#chatmessagereceived
  // Android: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk#chat_message_received
  final Function(
      String senderId,
      String message,
      bool isPrivate,
      )? onChatMessageReceived;

  // iOS: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk/#chattoggled
  // Android: https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk#chat_toggled
  final Function(bool isOpen)? onChatToggled;

  /// The native view got closed.
  final Function()? onClosed;

  JitsiMeetListener({
    this.onOpened,
    this.onReadyToClose,
    this.onConferenceWillJoin,
    this.onConferenceJoined,
    this.onConferenceTerminated,
    this.onAudioMutedChanged,
    this.onVideoMutedChanged,
    this.onScreenShareToggled,
    this.onParticipantJoined,
    this.onParticipantLeft,
    this.onParticipantsInfoRetrieved,
    this.onChatMessageReceived,
    this.onChatToggled,
    this.onClosed,
  });
}
