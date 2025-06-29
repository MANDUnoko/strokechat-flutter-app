import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    setState(() => _isLoading = true);
    final UserModel? user = await ApiService.loadUserFromToken();
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/home', arguments: user);
    }
  }

  Future<void> _login() async {
    if (_employeeIdController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = '아이디와 비밀번호를 모두 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = await ApiService.loginUser(
      _employeeIdController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/home', arguments: user);
    } else {
      setState(() =>
          _errorMessage = '로그인 실패. 아이디 또는 비밀번호를 확인해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputStyle = const TextStyle(fontSize: 16, color: Colors.black87);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // 로고
                Center(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 8),

                // 안내 문구
                Text(
                  '로그인하여 챗봇 서비스를 이용하세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 32),

                // 아이디 입력
                TextField(
                  controller: _employeeIdController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: '아이디',
                    hintText: '병원에서 제공받은 아이디를 입력해주세요',
                    prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.grey.shade600),
                  ),
                  style: inputStyle,
                ),

                const SizedBox(height: 16),

                // 비밀번호 입력
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '비밀번호를 입력해주세요',
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade600),
                  ),
                  style: inputStyle,
                  onSubmitted: (_) => _login(),
                ),

                const SizedBox(height: 24),

                // 에러 메시지
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: theme.elevatedButtonTheme.style,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('로그인'),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

