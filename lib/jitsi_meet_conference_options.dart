import 'jitsi_meet_user_info.dart';

class JitsiMeetConferenceOptions {
  final String? serverURL;
  final String room;
  final String? token;
  late final Map<String, Object?>? configOverrides;
  final Map<String, Object?>? featureFlags;
  final JitsiMeetUserInfo? userInfo;

  JitsiMeetConferenceOptions({
    this.serverURL,
    required this.room,
    this.token,
    this.configOverrides,
    this.featureFlags,
    this.userInfo
  });
}