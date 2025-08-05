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

class _HappyBotPageState extends State<HappyBotPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));
    _typingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
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

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingAnimation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final animationValue = (_typingAnimation.value - delay).clamp(0.0, 1.0);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: Transform.scale(
                            scale: 0.5 + (animationValue * 0.5),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3 + (animationValue * 0.7)),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'HappyBot is typing...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          image: const AssetImage('assets/icons/health.png'),
                          fit: BoxFit.none,
                          alignment: Alignment.center,
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

                  Column(
                    children: [
                      // Header
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
                              child: Column(
                                children: [
                                  Expanded(
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
                                  // Show typing indicator when bot is typing
                                  // You'll need to add an isTyping property to your ChatViewModel
                                  if (viewModel.isTyping) _buildTypingIndicator(),
                                ],
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