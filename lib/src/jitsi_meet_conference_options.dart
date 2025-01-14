import 'jitsi_meet_user_info.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

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

  static JitsiMeetConferenceOptions fromUrl(String roomLink) {
    final uri = Uri.parse(roomLink);

    final domain = uri.host;
    final roomName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;

    if (roomName == null) {
      throw Exception('Incorrect room link');
    }

    final options = JitsiMeetConferenceOptions(
      room: roomName,
      serverURL: 'https://$domain',
      configOverrides: {},
      featureFlags: {},
      userInfo: JitsiMeetUserInfo(),
    );

    if (uri.queryParameters.isNotEmpty) {
      uri.queryParameters.forEach((key, value) {
        if (key.startsWith('userInfo.')) {
          switch (key) {
            case 'userInfo.displayName':
              options.userInfo?.displayName = value.replaceAll('"', '');
              break;
            case 'userInfo.email':
              options.userInfo?.email = value.replaceAll('"', '');
              break;
            case 'userInfo.avatar':
              options.userInfo?.avatar = value.replaceAll('"', '');
              break;
          }
        } else if (key.startsWith('config.')) {
          switch (key) {
            case 'config.startWithAudioMuted':
              options.configOverrides?['startWithAudioMuted'] = value == 'true';
              break;
            case 'config.startWithVideoMuted':
              options.configOverrides?['startWithVideoMuted'] = value == 'true';
              break;
            case 'config.disableInitialGUM':
              options.configOverrides?['disableInitialGUM'] = value == 'true';
              break;
            case 'config.toolbarButtons':
              try {
                final buttons = List<String>.from(jsonDecode(value));
                options.configOverrides?['toolbarButtons'] = buttons;
              } catch (e) {
                debugPrint('Ошибка при обработке toolbarButtons: $e');
              }
              break;
          }
        } else if (key.startsWith('interfaceConfigOverwrite.')) {
          switch (key) {
            case 'interfaceConfigOverwrite.TOOLBAR_ALWAYS_VISIBLE':
              options.configOverrides?['toolbarAlwaysVisible'] = value == 'true';
              break;
            case 'interfaceConfigOverwrite.DISABLE_JOIN_LEAVE_NOTIFICATIONS':
              options.configOverrides?['disableJoinLeaveNotifications'] = value == 'true';
              break;
          }
        } else {
          options.featureFlags?[key] = value == 'true';
        }
      });
    }

    return options;
  }
}
