class FeatureFlags{
  FeatureFlags._();

  /// FeatureFlags [welcomePageEnabled] : Flag indicating if the welcome page should be enabled.
  /// Default: disabled (false).
  static const String welcomePageEnabled = "welcomepage.enabled";

  /// FeatureFlags [audioFocusDisabled] : Flag indicating if the SDK should not require the audio focus.
  /// Used by apps that do not use Jitsi audio.
  /// Default: disabled (false).
  static const String audioFocusDisabled = "audio-focus.disabled";

  /// FeatureFlags [addPeopleEnabled] : Flag indicating if add-people functionality should be enabled.
  /// Default: enabled (true).
  static const String addPeopleEnabled = "add-people.enabled";

  /// FeatureFlags [audioMuteButtonEnabled] : Flag indicating if the audio mute button should be displayed.
  /// Default: enabled (true).
  static const String audioMuteButtonEnabled = "audio-mute.enabled";

  /// FeatureFlags [audioOnlyButtonEnabled] : Flag indicating that the Audio only button in the overflow menu is enabled.
  /// Default: enabled (true).
  static const String audioOnlyButtonEnabled = "audio-only.enabled";

  /// FeatureFlags [calenderEnabled] : Flag indicating if calendar integration should be enabled.
  /// Default: enabled (true) on Android, auto-detected on iOS.
  static const String calenderEnabled = "calendar.enabled";

  /// FeatureFlags [callIntegrationEnabled] : Flag indicating if call integration (CallKit on iOS, ConnectionService on Android) should be enabled.
  /// Default: enabled (true).
  static const String callIntegrationEnabled = "call-integration.enabled";

  /// FeatureFlags [carModeEnabled] : Flag indicating if car mode should be enabled.
  /// Default: enabled (true).
  static const String carModeEnabled = "car-mode.enabled";

  /// FeatureFlags [closeCaptionsEnabled] : Flag indicating if close captions should be enabled.
  /// Default: enabled (true).
  static const String closeCaptionsEnabled = "close-captions.enabled";

  /// FeatureFlags [conferenceTimerEnabled] : Flag indicating if conference timer should be enabled.
  /// Default: enabled (true).
  static const String conferenceTimerEnabled = "conference-timer.enabled";

  /// FeatureFlags [chatEnabled] : Flag indicating if chat should be enabled.
  /// Default: enabled (true).
  static const String chatEnabled = "chat.enabled";

  /// FeatureFlags [filmstripEnabled] : Flag indicating if the filmstrip should be enabled.
  /// Default: enabled (true).
  static const String filmstripEnabled = "filmstrip.enabled";

  /// FeatureFlags [fullScreenEnabled] : Flag indicating if fullscreen (immersive) mode should be enabled.
  /// Default: enabled (true).
  static const String fullScreenEnabled = "fullscreen.enabled";

  /// FeatureFlags [helpButtonEnabled] : Flag indicating if the Help button should be enabled.
  /// Default: enabled (true).
  static const String helpButtonEnabled = "help.enabled";

  /// FeatureFlags [inviteEnabled] : Flag indicating if invite functionality should be enabled.
  /// Default: enabled (true).
  static const String inviteEnabled = "invite.enabled";

  /// FeatureFlags [androidScreenSharingEnabled] : Flag indicating if screen sharing should be enabled in android.
  /// Default: enabled (true).
  static const String androidScreenSharingEnabled = "android.screensharing.enabled";

  /// FeatureFlags [speakerStatsEnabled] : Flag indicating if speaker statistics should be enabled.
  /// Default: enabled (true).
  static const String speakerStatsEnabled = "speakerstats.enabled";

  /// FeatureFlags [kickOutEnabled] : Flag indicating if kickout is enabled.
  /// Default: enabled (true).
  static const String kickOutEnabled = "kick-out.enabled";

  /// FeatureFlags [liveStreamingEnabled] : Flag indicating if live-streaming should be enabled.
  /// Default: auto-detected.
  static const String liveStreamingEnabled = "live-streaming.enabled";

  /// FeatureFlags [lobbyModeEnabled] : Flag indicating if lobby mode button should be enabled.
  /// Default: enabled.
  static const String lobbyModeEnabled = "lobby-mode.enabled";

  /// FeatureFlags [meetingNameEnabled] : Flag indicating if displaying the meeting name should be enabled.
  /// Default: enabled (true).
  static const String meetingNameEnabled = "meeting-name.enabled";

  /// FeatureFlags [meetingPasswordEnabled] : Flag indicating if the meeting password button should be enabled.
  /// Note that this flag just decides on the button, if a meeting has a password set, the password dialog will still show up.
  /// Default: enabled (true).
  static const String meetingPasswordEnabled = "meeting-password.enabled";

  /// FeatureFlags [notificationEnabled] : Flag indicating if the notifications should be enabled.
  /// Default: enabled (true).
  static const String notificationEnabled = "notifications.enabled";

  /// FeatureFlags [overflowMenuEnabled] : Flag indicating if the audio overflow menu button should be displayed.
  /// Default: enabled (true).
  static const String overflowMenuEnabled = "overflow-menu.enabled";

  /// FeatureFlags [pipEnabled] : Flag indicating if Picture-in-Picture should be enabled.
  /// Default: auto-detected.
  static const String pipEnabled = "pip.enabled";

  /// FeatureFlags [pipWhileScreenSharingEnabled] : Flag indicating if Picture-in-Picture button should be shown while screen sharing.
  /// Default: disabled (false).
  static const String pipWhileScreenSharingEnabled = "pip-while-screen-sharing.enabled";

  /// FeatureFlags [preJoinPageEnabled] : Flag indicating if the prejoin page should be enabled.
  /// Default: enabled (true).
  static const String preJoinPageEnabled = "prejoinpage.enabled";

  /// FeatureFlags [preJoinPageHideDisplayName] :Flag indicating if the participant name editing field should be displayed on the prejoin page.
  /// Default: disabled (false).
  static const String preJoinPageHideDisplayName = "prejoinpage.hideDisplayName";

  /// FeatureFlags [raiseHandEnabled] :Flag indicating if raise hand feature should be enabled.
  /// Default: enabled.
  static const String raiseHandEnabled = "raise-hand.enabled";

  /// FeatureFlags [reactionsEnabled] : Flag indicating if the reactions feature should be enabled.
  /// Default: enabled (true).
  static const String reactionsEnabled = "reactions.enabled";

  /// FeatureFlags [recordingEnabled] : Flag indicating if recording should be enabled.
  /// Default: auto-detected.
  static const String recordingEnabled = "recording.enabled";

  /// FeatureFlags [replaceParticipant] : Flag indicating if the user should join the conference with the replaceParticipant functionality.
  /// Default: (false).
  static const String replaceParticipant = "replace.participant";

  /// FeatureFlags [securityOptionEnabled] : Flag indicating if the security options button should be enabled.
  /// Default: enabled (true).
  static const String securityOptionEnabled = "security-options.enabled";

  /// FeatureFlags [serverUrlChangeEnabled] : Flag indicating if server URL change is enabled.
  /// Default: enabled (true).
  static const String serverUrlChangeEnabled = "server-url-change.enabled";

  /// FeatureFlags [settingsEnabled] : Flag indicating if settings should be enabled.
  /// Default: enabled (true).
  static const String settingsEnabled = "settings.enabled";

  /// FeatureFlags [tileViewEnabled] : Flag indicating if tile view feature should be enabled.
  /// Default: enabled.
  static const String tileViewEnabled = "tile-view.enabled";

  /// FeatureFlags [videoMuteEnabled] : Flag indicating if the video mute button should be displayed.
  /// Default: enabled (true).
  static const String videoMuteEnabled = "video-mute.enabled";

  /// FeatureFlags [videoShareEnabled] : Flag indicating if the video share button should be enabled
  /// Default: enabled (true).
  static const String videoShareEnabled = "video-share.enabled";

  /// FeatureFlags [toolboxEnabled] : Flag indicating if the toolbox should be enabled
  /// Default: enabled.
  static const String toolboxEnabled = "toolbox.enabled";

  /// FeatureFlags [resolution] : Flag indicating the local and (maximum) remote video resolution. Overrides the server configuration.
  /// Default: (unset).
  static const String resolution = "resolution";

  /// FeatureFlags [unsafeRoomWarningEnabled] : Flag indicating if the unsafe room warning should be enabled.
  /// Default: disabled (false).
  static const String unsafeRoomWarningEnabled = "unsaferoomwarning.enabled";

  /// FeatureFlags [iosRecordingEnabled] : Flag indicating if recording should be enabled in iOS.
  /// Default: disabled (false).
  static const String iosRecordingEnabled = "ios.recording.enabled";

  /// FeatureFlags [iosScreenSharingEnabled] : Flag indicating if screen sharing should be enabled in iOS.
  /// Default: disabled (false).
  static const String iosScreenSharingEnabled = "ios.screensharing.enabled";

  /// FeatureFlags [toolboxAlwaysVisible] : Flag indicating if the toolbox should be always be visible
  /// Default: disabled (false).
  static const String toolboxAlwaysVisible = "toolbox.alwaysVisible";

}