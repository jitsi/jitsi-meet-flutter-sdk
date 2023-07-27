import 'jitsi_meet_flutter_sdk_platform_interface.dart';

import 'jitsi_meet_event_listener.dart';
import 'jitsi_meet_conference_options.dart';
import 'method_response.dart';

class JitsiMeetFlutterSdk {
  Future<String?> getPlatformVersion() {
    return JitsiMeetFlutterSdkPlatform.instance.getPlatformVersion();
  }

  Future<MethodResponse> join(JitsiMeetConferenceOptions options, [JitsiMeetEventListener? listener]) async{
    return await JitsiMeetFlutterSdkPlatform.instance.join(
        options,
        listener ?? JitsiMeetEventListener()
    );
  }
}
