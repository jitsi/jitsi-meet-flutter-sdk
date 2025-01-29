import 'package:flutter/material.dart';
import 'package:jitsi_meet_govar_flutter_sdk/jitsi_meet_govar_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: double.infinity,
              height: 600,
              child: JitsiMeetWidget(room: 'https://meet.govar.online/govar_speaking_club'),
            ),
            SizedBox(
              width: double.infinity,
              height: 150,
              child: Text('Bottom bar'),
            )
          ],
        ),
      ),
    );
  }
}