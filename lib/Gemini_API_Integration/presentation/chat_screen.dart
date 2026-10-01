import 'package:flutter/material.dart';
import 'package:flutter_application_4/Gemini_API_Integration/controller/gemini_controller.dart';
import 'package:flutter_application_4/Gemini_API_Integration/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(geminiControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI-Chat-Bot",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 8, 60, 103),
      ),
      body: chat.when(
        data: (data) {
          return Column(
            children: [
              Expanded(child: ChatList(data: data)),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: ChatTextField(chatController: chatController),
              ),
            ],
          );
        },
        error: (error, stack) {
          return Text(error.toString());
        },
        loading: () => Center(child: const CircularProgressIndicator()),
      ),
    );
  }
}

class ChatList extends StatefulWidget {
  final List<UserModel> data;

  const new({super.key, required this.data});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant ChatList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.data.length != oldWidget.data.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.data.length,
        itemBuilder: (context, index) {
          final message = widget.data[index];

          return Align(
            alignment: message.isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 270),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: message.isUser
                        ? const Color.fromARGB(255, 8, 60, 103)
                        : Colors.grey[300],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),

                    child: message.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black54,
                            ),
                          )
                        : Text(
                            message.text,
                            style: TextStyle(
                              color: message.isUser
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                  ),
                ),

                if (!message.isLoading)
                  Text(
                    message.timeStamp.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChatTextField extends ConsumerWidget {
  final TextEditingController chatController;

  const new({super.key, required this.chatController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: chatController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        GestureDetector(
          onTap: () async {
            if (chatController.text.trim().isNotEmpty) {
              DateTime now = DateTime.now();

              String formatedString = DateFormat('hh:mm a').format(now);

              UserModel userPrompt = UserModel(
                text: chatController.text.trim(),
                isUser: true,
                timeStamp: formatedString,
                isLoading: false,
              );

              await ref
                  .read(geminiControllerProvider.notifier)
                  .postData(userModel: userPrompt);
            }
          },
          child: Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 8, 60, 103),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Send",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
