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

  /// Whether end-to-end encryption should be enabled for this conference.
  ///
  /// E2EE on mobile uses an externally managed shared key (AES-GCM), so
  /// [e2eeKey] must be set as well. All participants must join with the same
  /// key. When enabled, `e2ee.externallyManagedKey` is forced to true in the
  /// conference config.
  ///
  /// NOTE: this requires a Jitsi Meet mobile SDK build with E2EE support
  /// (see E2EE-IMPLEMENTATION-GUIDE.md). On the stock SDK it has no effect.
  final bool e2eeEnabled;

  /// The shared E2EE key (passphrase) used to derive the media encryption key.
  /// Must be distributed to all participants through a secure channel.
  final String? e2eeKey;

  JitsiMeetConferenceOptions(
      {this.serverURL,
      required this.room,
      this.token,
      this.configOverrides,
      this.featureFlags,
      this.userInfo,
      this.e2eeEnabled = false,
      this.e2eeKey});
}
