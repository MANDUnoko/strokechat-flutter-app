import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class InitChatScreen extends StatefulWidget {
  final Map<String, dynamic> args;

  const InitChatScreen({super.key, required this.args});

  @override
  State<InitChatScreen> createState() => _InitChatScreenState();
}

class _InitChatScreenState extends State<InitChatScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeChatSession();
  }

  Future<void> _initializeChatSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String patientUuid = widget.args['patient_uuid'] as String;
    final String sourceTable = widget.args['source_table'] as String;
    final String sourceId = widget.args['source_id'] as String;
    final String patientDisplayName = widget.args['patient_display_name'] as String;
    final String resultOverview = widget.args['result_overview'] as String;

    try {
      final Map<String, dynamic>? response = await ApiService.initChatSession(
        patientUuid: patientUuid,
        sourceTable: sourceTable,
        sourceId: sourceId,
      );

      setState(() {
        _isLoading = false;
      });

      if (response != null) {
        final String sessionId = response['session_id'] as String;
        final String initialMessageContent = response['message'] as String;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              sessionId: sessionId,
              patientUuid: patientUuid,
              patientDisplayName: patientDisplayName,
              sourceId: sourceId,
              sourceTable: sourceTable,
              initialMessage: ChatMessage(
                sender: 'bot',
                content: initialMessageContent,
                sentAt: DateTime.now(),
              ),
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'AI 결과를 불러오지 못했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '서버 오류로 결과를 불러올 수 없습니다. 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 완전한 흰 배경
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.args['patient_display_name']}님 결과 요약',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: _isLoading
            ? _buildLoading(context)
            : _errorMessage != null
                ? _buildError(context)
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final String displayName = widget.args['patient_display_name'] as String;
    final String resultOverview = widget.args['result_overview'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.black87,
            strokeWidth: 3,
          ),
          const SizedBox(height: 36),
          Text(
            '$displayName님,\n${resultOverview.replaceAll('\n', ' ')}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'AI 챗봇이 결과 설명을 준비 중입니다.\n잠시만 기다려주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
          const SizedBox(height: 24),
          const Text(
            '요약을 불러오지 못했습니다.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              elevation: 1,
            ),
            child: const Text(
              '돌아가기',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

