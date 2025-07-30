import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/chatbot/viewmodals/chat_view_model.dart';
import 'package:mindcare/presentation/pages/chatbot/viewmodals/language_selector.dart';
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<ChatViewModel>(
            builder: (context, viewModel, _) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToBottom());
              return Stack(
                children: [
                  // Backdrop effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          image: const AssetImage('assets/icons/health.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.9),
                            BlendMode.lighten,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // White backdrop overlay with frosted glass effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.6),
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Decorative elements
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF008F76).withOpacity(0.05),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -60,
                    left: -60,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0066CC).withOpacity(0.04),
                      ),
                    ),
                  ),

                  // Main Content
                  Column(
                    children: [
                      // Header with enhanced design
                      // Replace the existing header Container in your HappyBotPage with this:

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008F76),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Language selector on the left
                            LanguageSelector(),

                            // Centered title
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.psychology,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Happy Bot",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Empty space to balance the layout
                            SizedBox(width: 40),
                          ],
                        ),
                      ),

                      // Chat messages with backdrop effect
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                itemCount: viewModel.messages.length,
                                itemBuilder: (context, index) {
                                  final message = viewModel.messages[index];
                                  return MessageBubble(message: message);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Input area with frosted glass effect
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              spreadRadius: 1,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  hintText: 'Type your message...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16),
                                ),
                                onSubmitted: (text) {
                                  if (text.trim().isNotEmpty) {
                                    viewModel.sendMessage(text);
                                    _messageController.clear();
                                  }
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF008F76),
                                    Color(0xFF0066CC)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.send_rounded,
                                    color: Colors.white),
                                onPressed: () {
                                  if (_messageController.text
                                      .trim()
                                      .isNotEmpty) {
                                    viewModel
                                        .sendMessage(_messageController.text);
                                    _messageController.clear();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
