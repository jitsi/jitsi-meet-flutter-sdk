class JitsiMeetEventListener {
  final Function(String url)? conferenceJoined;

  final Function(String url, Object? error)? conferenceTerminated;

  final Function(String url)? conferenceWillJoin;

  final Function(String? email, String? name, String? role, String? participantId)? participantJoined;

  final Function(String? participantId)? participantLeft;

  final Function(bool muted)? audioMutedChanged;

  final Function(bool muted)? videoMutedChanged;

  final Function(String senderId, String message)? endpointTextMessageReceived;

  final Function(String participantId, bool sharing)? screenShareToggled;

  final Function(String senderId, String message, bool isPrivate)? chatMessageReceived;

  final Function(bool isOpen)? chatToggled;

  final Function(String participantsInfo)? participantsInfoRetrieved;

  final Function()? readyToClose;

  JitsiMeetEventListener({
    this.conferenceJoined,
    this.conferenceTerminated,
    this.conferenceWillJoin,
    this.participantJoined,
    this.participantLeft,
    this.audioMutedChanged,
    this.videoMutedChanged,
    this.endpointTextMessageReceived,
    this.screenShareToggled,
    this.participantsInfoRetrieved,
    this.chatMessageReceived,
    this.chatToggled,
    this.readyToClose
  });
}
