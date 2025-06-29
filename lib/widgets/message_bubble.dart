import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final colorScheme = Theme.of(context).colorScheme;
    final bubbleColor = isMe ? colorScheme.primary : colorScheme.surfaceVariant;
    final textColor = isMe ? Colors.white : colorScheme.onSurface;
    final timeText = DateFormat('HH:mm').format(message.sentAt);

    return Align(
      alignment: alignment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 16 : 4),
            topRight: Radius.circular(isMe ? 4 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: message.content,
              shrinkWrap: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: textColor, fontSize: 15.0, height: 1.5),
                strong: TextStyle(color: textColor, fontSize: 15.0, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              timeText,
              style: TextStyle(
                color: textColor.withOpacity(0.6),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}