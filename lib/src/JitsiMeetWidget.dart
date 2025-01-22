
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class JitsiMeetWidget extends StatelessWidget {
  final String room;

  const JitsiMeetWidget({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'JitsiNativeView',
        creationParams: {
          'room': room,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'JitsiNativeView',
        creationParams: {
          'room': room
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