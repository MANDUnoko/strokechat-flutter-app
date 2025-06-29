import 'package:uuid/uuid.dart'; // UUID 사용
import 'package:intl/intl.dart'; // 날짜 포맷팅

// 채팅 메시지 모델 (bot 또는 user의 메시지)
class ChatMessage {
  final String sender; // 메시지 발신자 (bot 또는 user)
  final String content; // 메시지 내용
  final DateTime sentAt; // 메시지 전송 시각

  ChatMessage({
    required this.sender,
    required this.content,
    required this.sentAt,
  });

  // JSON 데이터로부터 ChatMessage 객체를 생성하는 팩토리 메서드
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String).toLocal(), // UTC로 저장된 시간을 로컬 시간으로 변환
    );
  }

  // ChatMessage 객체를 JSON 데이터로 변환하는 메서드 (보낼 때 필요할 수 있음)
  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'content': content,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}

// 채팅 세션 모델 (전체 대화 기록 관리)
class ChatSession {
  final String sessionId; // 세션 고유 ID
  final String patientUuid; // 환자 UUID
  final String? patientDisplayName; // 환자 표시 이름 (선택 사항)
  final String sourceTable; // AI 결과 테이블명 (예: 'gene_ai_result')
  final String sourceId; // AI 결과 고유 ID
  final DateTime createdAt; // 세션 생성 시각

  ChatSession({
    required this.sessionId,
    required this.patientUuid,
    this.patientDisplayName,
    required this.sourceTable,
    required this.sourceId,
    required this.createdAt,
  });

  // JSON 데이터로부터 ChatSession 객체를 생성하는 팩토리 메서드
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['session_id'] as String,
      patientUuid: json['patient_uuid'] as String,
      patientDisplayName: json['patient_display_name'] as String?,
      sourceTable: json['source_table'] as String,
      sourceId: json['source_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(), // UTC 시간을 로컬 시간으로 변환
    );
  }

  // 세션 생성 날짜를 예쁘게 포맷팅
  String get formattedDate {
    return DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(createdAt);
  }
}

// AI 유전자 분석 결과 모델 (FastAPI GeneAIResultSchema와 일치)
class GeneAIResult {
  final String id; // AI 결과 고유 ID (UUID)
  final String patientId; // 환자 ID (UUID)
  final double confidenceScore; // 신뢰도 점수
  final String modelName; // 모델 이름
  final String? modelVersion; // 모델 버전 (Nullable)
  final String resultText; // 분석 결과 텍스트
  final DateTime createdAt; // 결과 생성 시각

  GeneAIResult({
    required this.id,
    required this.patientId,
    required this.confidenceScore,
    required this.modelName,
    this.modelVersion,
    required this.resultText,
    required this.createdAt,
  });

  // JSON 데이터로부터 GeneAIResult 객체를 생성하는 팩토리 메서드
  factory GeneAIResult.fromJson(Map<String, dynamic> json) {
    return GeneAIResult(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      modelName: json['model_name'] as String,
      modelVersion: json['model_version'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(), // UTC 시간을 로컬 시간으로 변환
      resultText: json['result_text'] as String,
    );
  }

  // 결과 생성 날짜를 예쁘게 포맷팅
  String get formattedDate {
    return DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(createdAt);
  }
}
