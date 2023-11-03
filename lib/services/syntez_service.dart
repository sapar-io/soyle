
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SyntezService {
  static const String _apiKey = "AQVNy1yNQTsZxAbWLU317slfpHwrLK3RJrZtmSs7";

  static Future<http.Response> _synthesizeSpeech(String text, String languageCode, String voice) async {
    final http.Response response = await http.post(
      Uri.parse('https://tts.api.cloud.yandex.net/speech/v1/tts:synthesize'),
      headers: {
        'Authorization': 'Api-Key $_apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'text': text,
        'lang': languageCode,
        'voice': voice, // Имя голоса, можно заменить на другие
        'format': 'mp3',
      },
    );

    return response;
  }

  static dynamic getAudio(String text, String languageCode, String voice) async {
    try {
      final http.Response response = await _synthesizeSpeech(text, languageCode, voice);

      if (response.statusCode != 200) {
        throw Exception('Ошибка при синтезе речи: ${response.body}');
      }

      // Сохраняем звуковой файл в кэш-директории приложения
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/speech.mp3');
      await tempFile.writeAsBytes(response.bodyBytes);

      return tempFile;
    } catch (e) {
      print(e.toString());
    }
  }
}