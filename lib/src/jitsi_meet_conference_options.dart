import 'jitsi_meet_user_info.dart';

/// This object encapsulates all the options that can be tweaked when joining a conference.
class JitsiMeetConferenceOptions {
  /// Server where the conference should take place.
  final String? serverURL;

  /// Room name.
  final String room;

  /// JWT token used for authentication.
  final String? token;

  /// Config overrides See: https://github.com/jitsi/jitsi-meet/blob/master/config.js.
  late final Map<String, Object?>? configOverrides;

  /// Feature flags. See: https://github.com/jitsi/jitsi-meet/blob/master/react/features/base/flags/constants.ts.
  final Map<String, Object?>? featureFlags;

  /// Information about the local user. It will be used in absence of a token.
  final JitsiMeetUserInfo? userInfo;

  JitsiMeetConferenceOptions(
      {this.serverURL,
      required this.room,
      this.token,
      this.configOverrides,
      this.featureFlags,
      this.userInfo});
}
