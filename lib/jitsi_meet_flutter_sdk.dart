import 'jitsi_meet_flutter_sdk_platform_interface.dart';

import 'jitsi_meet_listener.dart';
import 'jitsi_meet_options.dart';
import 'method_response.dart';

class JitsiMeetFlutterSdk {
  Future<String?> getPlatformVersion() {
    return JitsiMeetFlutterSdkPlatform.instance.getPlatformVersion();
  }

  Future<MethodResponse> join(JitsiMeetOptions options, JitsiMeetListener? listener) async{
    return await JitsiMeetFlutterSdkPlatform.instance.join(options, listener);
  }
}
