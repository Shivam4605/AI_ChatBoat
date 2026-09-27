import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_application_4/Gemini_API_Integration/models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeminiService {
  final Dio _dio;

  GeminiService({required this._dio});

  Future<String?> geminiChatBot({required UserModel userModel}) async {
    String url = 'https://api.groq.com/openai/v1/chat/completions';

    String userprompt =
        '''
            hey you are smart ai assistent build for giving the answer of user promt, you are just give the answer of user promt 
            basically related to Cricket games.

            and i have give some conditionn to you based on that condition you are giving the answers

            1) if the user are giving the and promt which are not related to the Criket game then you are just appologies to user
            and give the reason like i am not giving the answer for this promt because i have only build to give answer of promt which 
            is related to the Cricket game

            2) if the user promt are related to the Cricket game then give the proper 2 line answer to user based on there promt 
            which basically they have ask, answer are generate only in 2 line 

            also i have give the user promt below 
            this is the user promt : ${userModel.text}.
    ''';

    try {
      Map<String, dynamic> requestBody = {
        "model": "openai/gpt-oss-20b",
        "messages": [
          {"role": "user", "content": userprompt},
        ],
      };

      Response response = await _dio.post(url, data: requestBody);

      log("AI Response  ${response.data}");

      if (response.statusCode == 200) {
        log("Response : ${response.data}");

        String aiResponse = response.data['choices'][0]['message']['content'];

        log("AI Response : $aiResponse");

        return aiResponse;
      }
    } catch (e, stack) {
      log(e.toString());
      log(stack.toString());
    }

    return null;
  }
}

final dioProvider = Provider<Dio>((ref) {
  String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  return Dio(
    BaseOptions(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
    ),
  );
});

final geminiServiceProvider = Provider(
  (ref) => GeminiService(dio: ref.read(dioProvider)),
);
