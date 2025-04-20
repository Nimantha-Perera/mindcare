import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mindcare/domain/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  
  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: message.isFromUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          if (!message.isFromUser && message.senderName != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message.senderName!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: message.isFromUser 
                  ? Colors.grey.shade200 
                  : const Color(0xFFCFE8DE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: message.isFromUser
                ? Text(
                    message.text,
                    style: const TextStyle(fontSize: 16),
                  )
                : MarkdownBody(
                    data: message.text,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 16),
                      code: TextStyle(
                        backgroundColor: Colors.grey.shade200,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}