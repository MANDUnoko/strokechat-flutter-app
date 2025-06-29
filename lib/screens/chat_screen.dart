import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String sessionId;
  final String patientUuid;
  final String patientDisplayName;
  final String sourceId;
  final String sourceTable;
  final ChatMessage? initialMessage;

  const ChatScreen({
    super.key,
    required this.sessionId,
    required this.patientUuid,
    required this.patientDisplayName,
    required this.sourceId,
    required this.sourceTable,
    this.initialMessage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isSendingMessage = false;
  bool _isFetchingMessages = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      _messages.add(widget.initialMessage!);
      _scrollToBottom();
    } else {
      _fetchSessionMessages();
    }
  }

  Future<void> _fetchSessionMessages() async {
    setState(() => _isFetchingMessages = true);
    final messages = await ApiService.getSessionMessages(widget.sessionId);
    if (messages != null) {
      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
        _isFetchingMessages = false;
      });
      _scrollToBottom();
    } else {
      setState(() => _isFetchingMessages = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_isSendingMessage || _messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        sender: 'user',
        content: userMessage,
        sentAt: DateTime.now(),
      ));
      _isSendingMessage = true;
    });
    _scrollToBottom();

    final response = await ApiService.sendChatMessage(
      sessionId: widget.sessionId,
      userMessage: userMessage,
    );

    setState(() {
      _isSendingMessage = false;
      _messages.add(ChatMessage(
        sender: 'bot',
        content: response ?? '죄송합니다. 챗봇 응답을 받지 못했습니다. 다시 시도해주세요.',
        sentAt: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isInputDisabled = _isFetchingMessages || _isSendingMessage;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.patientDisplayName}님과의 채팅',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isFetchingMessages && _messages.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black87,
                      strokeWidth: 3,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(
                        message: message,
                        isMe: message.sender == 'user',
                      );
                    },
                  ),
          ),
          if (_isSendingMessage)
            const LinearProgressIndicator(
              color: Colors.black87,
              backgroundColor: Colors.white,
            ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: !isInputDisabled,
                      decoration: InputDecoration(
                        hintText: isInputDisabled ? '응답 대기 중...' : '메시지를 입력하세요...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: isInputDisabled ? null : (_) => _sendMessage(),
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: isInputDisabled ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isInputDisabled ? Colors.grey.shade300 : Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _isSendingMessage
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
