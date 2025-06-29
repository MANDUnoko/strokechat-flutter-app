// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // ApiService 임포트 필요 (다시 추가)
import '../models/user_model.dart'; // UserModel 임포트 필요

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    await Future.delayed(const Duration(seconds: 1)); // 개발 중 디버깅 지연

    if (token != null) {
      // 토큰이 있으면, 토큰으로부터 사용자 정보를 로드합니다.
      final UserModel? user = await ApiService.loadUserFromToken();

      if (user != null) {
        print('[SplashScreen] 토큰 유효, 홈 화면으로 사용자 정보와 함께 이동');
        // 홈 화면으로 이동할 때 user 객체 전달
        Navigator.of(context).pushReplacementNamed('/home', arguments: user);
      } else {
        // 토큰은 있지만 유효하지 않거나 사용자 정보 로드 실패 시 로그인 화면으로 이동
        print('[SplashScreen] 토큰은 있으나 사용자 정보 로드 실패, 로그인 화면으로 이동');
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      // 토큰이 없다면 로그인 화면으로 이동
      print('[SplashScreen] 토큰 없음, 로그인 화면으로 이동');
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/app_logo2.png', width: 400),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('로그인 상태 확인 중...'),
          ],
        ),
      ),
    );
  }
}

