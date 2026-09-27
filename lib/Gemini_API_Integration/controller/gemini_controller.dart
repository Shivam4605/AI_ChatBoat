import 'dart:async';
import 'dart:developer';

import 'package:flutter_application_4/Gemini_API_Integration/gemini_service/gemini_service.dart';
import 'package:flutter_application_4/Gemini_API_Integration/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class GeminiController extends AsyncNotifier<List<UserModel>> {
  @override
  FutureOr<List<UserModel>> build() {
    return [];
  }

  Future<void> postData({required UserModel userModel}) async {
    final message = state.value ?? [];

    final updatedUserBubble = userModel.copyWith(isLoading: false);

    final botLoadingBubble = UserModel(
      text: "AI is thinking...",
      isUser: false,
      timeStamp: userModel.timeStamp,
      isLoading: true,
    );

    state = AsyncData([...message, updatedUserBubble, botLoadingBubble]);

    await sendDataToGemini(
      previousMessages: [...message, updatedUserBubble],
      userModel: userModel,
    );
  }

  Future<void> sendDataToGemini({
    required List<UserModel> previousMessages,
    required UserModel userModel,
  }) async {
    try {
      String? aiResponse = await ref
          .read(geminiServiceProvider)
          .geminiChatBot(userModel: userModel);

      DateTime now = DateTime.now();
      String formatedString = DateFormat('hh:mm a').format(now);

      final botResponseBubble = UserModel(
        text: aiResponse ?? '',
        isUser: false,
        timeStamp: formatedString,
        isLoading: false,
      );

      state = AsyncData([...previousMessages, botResponseBubble]);
    } catch (e) {
      log("Gemini API Error: ${e.toString()}");

      final errorBubble = UserModel(
        text: "Sorry, the AI server is currently unavailable (503). Please try again shortly.",
        isUser: false,
        timeStamp: DateFormat('hh:mm a').format(DateTime.now()),
        isLoading: false,
      );

      state = AsyncData([...previousMessages, errorBubble]);
    }
  }
}

final geminiControllerProvider =
    AsyncNotifierProvider<GeminiController, List<UserModel>>(
      GeminiController.new,
    );
