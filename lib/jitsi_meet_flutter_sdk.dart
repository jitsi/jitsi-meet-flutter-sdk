import 'jitsi_meet_flutter_sdk_platform_interface.dart';

import 'method_response.dart';

class JitsiMeetFlutterSdk {
  Future<String?> getPlatformVersion() {
    return JitsiMeetFlutterSdkPlatform.instance.getPlatformVersion();
  }

  Future<MethodResponse> join() async{
    return await JitsiMeetFlutterSdkPlatform.instance.join();
  }
}
