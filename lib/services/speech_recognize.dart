import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SpeechRecognize {
  // static Future<String> getText(File audioFile) async {
  //   const String url = 'https://stt.api.cloud.yandex.net/speech/v1/stt:recognize';

  //   final String uuid = Uuid().v4();
  //   const String topic = 'general';
  //   const String lang = 'ru-RU';
  //   const int format = 3;
  //   const String _apiKey = "AQVNy1yNQTsZxAbWLU317slfpHwrLK3RJrZtmSs7";

  //   final Map<String, String> headers = {
  //     'Authorization': 'Api-Key $_apiKey',
  //     'Transfer-Encoding': 'chunked',
  //     'Content-Type': 'audio/x-pcm;bit=16;rate=16000',
  //     'X-RequestId': uuid,
  //   };
  //   final http.StreamedRequest request = http.StreamedRequest('POST', Uri.parse(url));
  //   request.headers.addAll(headers);

  //   final List<int> bytes = await audioFile.readAsBytes();
  //   request.sink.add(bytes);
  //   request.sink.close();

  //   final http.Response response = await http.Response.fromStream(await request.send());

  //   final result = response.body;

  //   return result;
  // }

  static Future<String> getText(File audioFile, String languageCode) async {
    const apiKey = "AQVNy1yNQTsZxAbWLU317slfpHwrLK3RJrZtmSs7";
    final url = 'https://stt.api.cloud.yandex.net/speech/v1/stt:recognize?lang=$languageCode&format=lpcm&sampleRateHertz=48000';

    final headers = {
      HttpHeaders.authorizationHeader: 'Api-Key $apiKey',
      "Transfer-Encoding": "chunked",
    };

    final bytes = await audioFile.readAsBytes();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: bytes,
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Ошибка при распознавании речи: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final result = data['result'];
    return result.isNotEmpty ? result : '';
  }
}