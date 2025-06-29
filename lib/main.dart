import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

// 스크린 임포트
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/chat_home_screen.dart';
import 'screens/gene_ai_results_list_screen.dart';
import 'screens/init_chat_screen.dart';
import 'screens/chat_screen.dart';

import '../constants/env.dart';

void main() {
  debugPrint('🔥 DJANGO_BASE_URL = ${Env.djangoBaseUrl}');
  debugPrint('🔥 FASTAPI_BASE_URL = ${Env.fastapiBaseUrl}');
  runApp(const StrokeChatApp());
}

class StrokeChatApp extends StatelessWidget {
  const StrokeChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stroke Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'NotoSansKR', // 기본 폰트 통일 (assets/fonts에 등록되어 있어야 함)
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C6E91), // 로고 텍스트 색상 기반
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C6E91), // 앱바 배경색
          foregroundColor: Colors.white, // 앱바 텍스트/아이콘
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C6E91),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 2,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2C6E91), width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          return ChatHomeScreen(key: ValueKey(args));
        },
        '/init-chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return InitChatScreen(args: args);
        },
        // 필요 시 ChatScreen 명시적 라우트 추가 가능
      },
    );
  }
}

