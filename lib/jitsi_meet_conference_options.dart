import 'jitsi_meet_user_info.dart';

class JitsiMeetConferenceOptions {
  final String room;
  final String? serverURL;
  final String? token;
  late final Map<String, Object?>? config;
  final Map<String, Object?>? featureFlags;
  final JitsiMeetUserInfo? userInfo;

  JitsiMeetConferenceOptions({
    required this.room,
    this.serverURL,
    this.token,
    this.config,
    this.featureFlags,
    this.userInfo
  });
}