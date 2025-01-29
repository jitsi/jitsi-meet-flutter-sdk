import 'dart:io';
import 'package:jitsi_meet_govar_flutter_sdk/src/method_response.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class JitsiAudioRecorder {
  final _recorder = AudioRecorder();

  Future<String> _getRecordingPath() async {
    final directory = await getTemporaryDirectory();
    final filePath = path.join(directory.path, 'recordings');
    final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    final dir = Directory(filePath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return path.join(filePath, fileName);
  }

  Future<MethodResponse> startRecording() async {
    if (!(await _recorder.hasPermission())) {
      return MethodResponse(isSuccess: false, message: 'User does not have microphone permissions');
    }

    final filePath = await _getRecordingPath();

    const config = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000
    );

    await _recorder.start(config, path: filePath);
    return MethodResponse(isSuccess: true, message: "Recording has started at path: $filePath");
  }

  Future<String?> stopRecording() async {
    if (await _recorder.isRecording()) {
      final path = await _recorder.stop();
      return path;
    }
    return null;
  }


}