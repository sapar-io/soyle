import 'dart:convert';

import 'package:http/http.dart' as http;

class GPT {
  static Future<String> generateText(String prompt) async {
    String url = "https://api.openai.com/v1/chat/completions";
    String apiKey = "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";

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey"
    };

    Map<String, dynamic> data = {
      "model": "gpt-3.5-turbo",
      "max_tokens": 100,
      "messages": [{"role": "user", "content": prompt}]
    };

    http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data)
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
      String text = json["choices"][0]["message"]["content"];
      return text;
    } else {
      throw Exception("Failed to generate text");
    }
  }
}