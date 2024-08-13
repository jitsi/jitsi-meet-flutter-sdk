class JitsiMeetEventListener {
  /// Called when a conference was joined.
  ///
  /// [url] : the conference URL
  final Function(String url)? conferenceJoined;

  /// Called when the active conference ends, be it because of user choice or because of a failure.
  ///
  /// [url] : the conference URL
  /// [error] : missing if the conference finished gracefully, otherwise contains the error message
  final Function(String url, Object? error)? conferenceTerminated;

  /// Called before a conference is joined.
  ///
  /// [url] : the conference URL
  final Function(String url)? conferenceWillJoin;

  /// Called when a participant has joined the conference.
  ///
  /// [email] : the email of the participant. It may not be set if the remote participant didn't set one.
  /// [name] : the name of the participant.
  /// [role] : the role of the participant.
  /// [participantId] : the id of the participant.
  final Function(
          String? email, String? name, String? role, String? participantId)?
      participantJoined;

  /// Called when a participant has left the conference.
  ///
  /// [participantId] : the id of the participant that left.
  final Function(String? participantId)? participantLeft;

  /// Called when the local participant's audio is muted or unmuted.
  ///
  /// [muted] : a boolean indicating whether the audio is muted or not.
  final Function(bool muted)? audioMutedChanged;

  /// Called when the local participant's video is muted or unmuted.
  ///
  /// [muted] : a boolean indicating whether the video is muted or not.
  final Function(bool muted)? videoMutedChanged;

  /// Called when an endpoint text message is received.
  ///
  /// [senderId] : the id of the participant that sent the message.
  /// [message] : the content of the message.
  final Function(String senderId, String message)? endpointTextMessageReceived;

  /// Called when a participant starts or stops sharing his screen.
  ///
  /// [participantId] : the id of the participant
  /// [sharing] : the state of screen share
  final Function(String participantId, bool sharing)? screenShareToggled;

  /// Called when a chat text message is received.
  ///
  /// [senderId] : the id of the participant that sent the message.
  /// [message] : the content of the message.
  /// [isPrivate] : `true` if the message is private, `false` otherwise.
  /// [timestamp] : the (optional) timestamp of the message.
  final Function(
          String senderId, String message, bool isPrivate, String? timestamp)?
      chatMessageReceived;

  /// Called when the chat dialog is opened or closed.
  ///
  /// [isOpen] : `true` if the chat dialog is open, `false` otherwise.
  final Function(bool isOpen)? chatToggled;

  /// Called when `retrieveParticipantsInfo` action is called.
  ///
  /// [participantsInfo] : a list of participants information as a string.
  final Function(String participantsInfo)? participantsInfoRetrieved;

  /// Called when the SDK is ready to be closed. No meeting is happening at this point.
  final Function()? readyToClose;

  /// Called when a custom overflow menu button is pressed.
  ///
  /// [buttonId] : the id of the button that was pressed.
  final Function(String buttonId)? customOverflowMenuButtonPressed;

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
    this.readyToClose,
    this.customOverflowMenuButtonPressed,
  });
}
