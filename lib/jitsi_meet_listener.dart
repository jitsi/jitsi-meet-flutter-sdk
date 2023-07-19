class JitsiMeetListener {
  final Function(String url)? conferenceJoined;

  final Function(String url, Object? error)? conferenceTerminated;

  final Function(String url)? conferenceWillJoin;

  final Function(String? email, String? name, String? role, String? participantId)? participantJoined;

  final Function(String? participantId)? participantLeft;

  final Function(bool isMuted)? audioMutedChanged;

  final Function(bool isMuted)? videoMutedChanged;

  final Function(String senderId, String message)? endpointTextMessageReceived;

  final Function(String participantId, bool isSharing)? screenShareToggled;

  final Function(String senderId, String message, bool isPrivate)? chatMessageReceived;

  final Function(bool isOpen)? chatToggled;

  final Function(Map<String, dynamic> participantsInfo, String requestId)? participantsInfoRetrieved;

  final Function()? readyToClose;

  JitsiMeetListener({
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
