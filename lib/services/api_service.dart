// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart'; // ChatSession, ChatMessage, GeneAIResult 포함
import '../constants/env.dart';

final url = Env.djangoBaseUrl + '/api/something';

class ApiService {
  // .env 파일에서 백엔드 URL 로드
  static final String _djangoBaseUrl = Env.djangoBaseUrl;
  static final String _fastApiBaseUrl = Env.fastapiBaseUrl;

  // 디버그를 위한 출력 함수
  static void _debugPrint(String message) {
    print('[ApiService Debug] $message');
  }

  // JWT 토큰 가져오기
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // JWT 토큰 저장
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    _debugPrint('JWT 토큰 저장 완료');
  }

  // JWT 토큰 삭제
  static Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _debugPrint('JWT 토큰 삭제 완료');
  }

  // --- 사용자 인증 관련 API (Django 백엔드) ---

  // 회원가입 기능은 제거되었습니다.


  // 로그인 및 JWT 토큰 획득
  static Future<UserModel?> loginUser(String employeeId, String password) async {
    _debugPrint('로그인 시도: $employeeId');
    final url = Uri.parse('$_djangoBaseUrl/api/accounts/token/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'employee_id': employeeId,
          'password': password,
        }),
      );

      _debugPrint('로그인 응답 상태 코드: ${response.statusCode}');
      _debugPrint('로그인 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final token = data['access'] as String; // access 토큰
        await _saveToken(token); // 토큰 저장

        // 토큰에서 사용자 정보 파싱 (직접 파싱하거나, Django에서 사용자 정보도 함께 보내주면 좋음)
        // 현재는 토큰에 담긴 정보만으로 UserModel 생성
        final decodedToken = _decodeJwt(token);
        _debugPrint('디코딩된 토큰: $decodedToken');
        _debugPrint('디코딩된 토큰["name"]의 실제 값: ${decodedToken['name']} (타입: ${decodedToken['name'].runtimeType})');
        _debugPrint('디코딩된 토큰["role"]의 실제 값: ${decodedToken['role']} (타입: ${decodedToken['role'].runtimeType})');

        // Django 로그인 API가 user_id, name, role 등을 직접 반환하지 않는 경우,
        // 토큰 페이로드에서 정보를 가져오거나, 별도의 user info API를 호출해야 합니다.
        // 현재는 토큰에서 employee_id, name, role, uuid를 바로 가져온다고 가정합니다.
        final user = UserModel(
          employeeId: decodedToken['employee_id'] ?? employeeId, // 토큰에 없으면 로그인 ID 사용
          name: decodedToken['name'] ?? 'Unknown',
          department: decodedToken['department'] ?? 'Unknown', // department는 토큰에 없을 수 있음
          role: decodedToken['role'] ?? 'etc',
          uuid: decodedToken['uuid'] as String?, // openmrs_uuid 대신 uuid로 변경
        );
        _debugPrint('로그인 성공: ${user.employeeId}');
        return user;
      } else {
        _debugPrint('로그인 실패: ${response.body}');
        return null;
      }
    } catch (e) {
      _debugPrint('로그인 중 네트워크 오류: $e');
      return null;
    }
  }

  // JWT 토큰 디코딩 헬퍼 함수 (토큰에서 정보 추출)
  static Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }
    final payload = _decodeBase64(parts[1]);
    final decoded = json.decode(payload);
    return decoded;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }
    return utf8.decode(base64Url.decode(output));
  }


  // --- 챗봇 및 AI 결과 관련 API (FastAPI 백엔드) ---

  // 환자의 모든 유전자 AI 결과 가져오기
  static Future<List<GeneAIResult>?> getGeneAIResultsForPatient(String patientUuid) async {
    _debugPrint('환자 UUID로 유전자 AI 결과 가져오기 시도: $patientUuid');
    // 여기에 /chatbot 접두사 추가
    final url = Uri.parse('$_fastApiBaseUrl/chatbot/gene-ai-results/$patientUuid'); 
    final token = await _getToken(); // 인증 토큰 필요

    if (token == null) {
      _debugPrint('토큰 없음: AI 결과 가져오기 불가');
      return null;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _debugPrint('AI 결과 응답 상태 코드: ${response.statusCode}');
      _debugPrint('AI 결과 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => GeneAIResult.fromJson(json)).toList();
      } else {
        _debugPrint('AI 결과 가져오기 실패: ${response.body}');
        return null;
      }
    } catch (e) {
      _debugPrint('AI 결과 가져오기 중 네트워크 오류: $e');
      return null;
    }
  }

  // 챗봇 세션 초기화 (AI 결과 요약)
  static Future<Map<String, dynamic>?> initChatSession({
    required String patientUuid,
    required String sourceTable,
    required String sourceId,
  }) async {
    _debugPrint('챗봇 세션 초기화 시도: patient=$patientUuid, source=$sourceTable, id=$sourceId');
    // 여기에 /chatbot 접두사 추가
    final url = Uri.parse('$_fastApiBaseUrl/chatbot/init'); 
    final token = await _getToken();

    if (token == null) {
      _debugPrint('토큰 없음: 세션 초기화 불가');
      return null;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'patient_uuid': patientUuid,
          'source_table': sourceTable,
          'source_id': sourceId,
        }),
      );

      _debugPrint('세션 초기화 응답 상태 코드: ${response.statusCode}');
      _debugPrint('세션 초기화 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'session_id': data['session_id'] as String,
          'message': data['message'] as String,
        };
      } else {
        _debugPrint('세션 초기화 실패: ${response.body}');
        return null;
      }
    } catch (e) {
      _debugPrint('세션 초기화 중 네트워크 오류: $e');
      return null;
    }
  }

  // 챗봇에게 메시지 전송 및 답변 받기
  static Future<String?> sendChatMessage({
    required String sessionId,
    required String userMessage,
  }) async {
    _debugPrint('챗봇 메시지 전송 시도: session=$sessionId, message=$userMessage');
    // 여기에 /chatbot 접두사 추가
    final url = Uri.parse('$_fastApiBaseUrl/chatbot/reply'); 
    final token = await _getToken();

    if (token == null) {
      _debugPrint('토큰 없음: 메시지 전송 불가');
      return null;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'session_id': sessionId,
          'user_message': userMessage,
        }),
      );

      _debugPrint('챗봇 답변 응답 상태 코드: ${response.statusCode}');
      _debugPrint('챗봇 답변 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['message'] as String;
      } else {
        _debugPrint('챗봇 답변 실패: ${response.body}');
        return null;
      }
    } catch (e) {
      _debugPrint('챗봇 메시지 전송 중 네트워크 오류: $e');
      return null;
    }
  }

  // 특정 세션의 모든 메시지 가져오기
  static Future<List<ChatMessage>?> getSessionMessages(String sessionId) async {
    _debugPrint('세션 메시지 가져오기 시도: session=$sessionId');
    // 여기에 /chatbot 접두사 추가
    final url = Uri.parse('$_fastApiBaseUrl/chatbot/session/$sessionId'); 
    final token = await _getToken();

    if (token == null) {
      _debugPrint('토큰 없음: 세션 메시지 가져오기 불가');
      return null;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _debugPrint('세션 메시지 응답 상태 코드: ${response.statusCode}');
      _debugPrint('세션 메시지 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> messagesJson = data['messages'];
        return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        _debugPrint('세션 메시지 가져오기 실패: ${response.body}');
        return null;
      }
    } catch (e) {
      _debugPrint('세션 메시지 가져오기 중 네트워크 오류: $e');
      return null;
    }
  }

  // 특정 환자의 모든 채팅 세션 가져오기
  static Future<List<ChatSession>?> getChatSessionsForPatient(String patientUuid) async {
    _debugPrint('환자 UUID로 채팅 세션 목록 가져오기 시도: $patientUuid');
    // 여기에 /chatbot 접두사 추가
    final url = Uri.parse('$_fastApiBaseUrl/chatbot/sessions?patient_uuid=$patientUuid'); 
    final token = await _getToken();

    if (token == null) {
      _debugPrint('토큰 없음: 채팅 세션 목록 가져오기 불가');
      return null;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _debugPrint('채팅 세션 목록 응답 상태 코드: ${response.statusCode}');
      _debugPrint('채팅 세션 목록 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> sessionsJson = data['sessions'];
        return sessionsJson.map((json) => ChatSession.fromJson(json)).toList();
      } else {
        _debugPrint('채팅 세션 목록 가져오기 실패: ${response.body}');
        return null;
      }
    } catch (e) {
      _debugPrint('채팅 세션 목록 가져오기 중 네트워크 오류: $e');
      return null;
    }
  }

    // JWT 토큰으로부터 사용자 정보를 로드하는 함수
  // (예: 앱 재시작 시 저장된 토큰으로 사용자 정보 복원)
  static Future<UserModel?> loadUserFromToken() async {
    final token = await _getToken();
    if (token == null) {
      _debugPrint('토큰 없음: 사용자 정보 로드 불가');
      return null;
    }

    try {
      final decodedToken = _decodeJwt(token);
      _debugPrint('토큰으로부터 사용자 정보 로드 시도: $decodedToken');

      // 토큰 페이로드에서 직접 UserModel 생성 (로그인 시와 동일)
      final user = UserModel(
        employeeId: decodedToken['employee_id'] as String,
        name: decodedToken['name'] ?? 'Unknown',
        department: decodedToken['department'] ?? 'Unknown',
        role: decodedToken['role'] ?? 'etc',
        uuid: decodedToken['uuid'] as String?, // openmrs_uuid 대신 uuid로 변경
      );
      _debugPrint('토큰으로부터 사용자 정보 로드 성공: ${user.employeeId}');
      return user;
    } catch (e) {
      _debugPrint('토큰으로부터 사용자 정보 로드 실패: $e');
      await _deleteToken(); // 유효하지 않은 토큰이면 삭제
      return null;
    }
  }

  // 로그아웃 (토큰 삭제)
  static Future<void> logout() async {
    await _deleteToken();
  }
}


