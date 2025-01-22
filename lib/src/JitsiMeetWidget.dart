
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class JitsiMeetWidget extends StatelessWidget {
  final String roomUrl;

  const JitsiMeetWidget({super.key, required this.roomUrl});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'JitsiNativeView',
        creationParams: {
          'roomUrl': roomUrl,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'JitsiNativeView',
        creationParams: {
          'roomUrl': roomUrl
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return const Center(
        child: Text('Jitsi Meet is not supported on this platform.'),
      );
    }
  }
}