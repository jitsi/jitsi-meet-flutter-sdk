/// Information about the local user. It will be used in absence of a token.
class JitsiMeetUserInfo {
  /// User display name.
  String? displayName;

  /// User email.
  String? email;

  /// URL for the user avatar.
  String? avatar;

  JitsiMeetUserInfo({this.displayName, this.email, this.avatar});
}
