
import 'jitsi_meet_flutter_sdk_platform_interface.dart';

class JitsiMeetFlutterSdk {
  Future<String?> getPlatformVersion() {
    return JitsiMeetFlutterSdkPlatform.instance.getPlatformVersion();
  }

  Future<void> join() async{
    return await JitsiMeetFlutterSdkPlatform.instance.join();
  }
}
