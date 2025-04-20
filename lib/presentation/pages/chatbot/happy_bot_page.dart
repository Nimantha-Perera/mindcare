import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/chatbot/viewmodals/chat_view_model.dart';
import 'package:mindcare/presentation/pages/chatbot/widgets/message_bubble.dart';
import 'package:provider/provider.dart';

class HappyBotPage extends StatefulWidget {
  const HappyBotPage({Key? key}) : super(key: key);

  @override
  State<HappyBotPage> createState() => _HappyBotPageState();
}

class _HappyBotPageState extends State<HappyBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Scaffold(
        body: SafeArea(
          child: Consumer<ChatViewModel>(
            builder: (context, viewModel, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
              return Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF008F76),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Happy Bot",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  // Chat messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: viewModel.messages.length,
                      itemBuilder: (context, index) {
                        final message = viewModel.messages[index];
                        return MessageBubble(message: message);
                      },
                    ),
                  ),
                  
                  // Input area
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Write message',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (text) {
                                viewModel.sendMessage(text);
                                _messageController.clear();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF0066CC),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.white),
                            onPressed: () {
                              viewModel.sendMessage(_messageController.text);
                              _messageController.clear();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}