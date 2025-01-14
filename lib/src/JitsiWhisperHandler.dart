import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JitsiWhisperHandler {
  final String bearer;
  final String model;

  JitsiWhisperHandler({
    required this.bearer,
    this.model = 'whisper-1'
  });

  Future<String?>transcribeWithWhisper(String filePath) async {
    final file = File(filePath);
    final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/transcriptions')
    );

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.headers['Authorization'] = 'Bearer $bearer';
    request.fields['model'] = model;

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      debugPrint('Record transcription: $responseData');
      return responseData;
    } else {
      debugPrint('Whisper response error: ${response.statusCode}');
      return null;
    }
  }

}

