
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class JitsiMeetWidget extends StatelessWidget {
  final String roomUrl;

  const JitsiMeetWidget({super.key, required this.roomUrl});

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: 'JitsiNativeView',
      creationParams: {
        'roomUrl': roomUrl
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}