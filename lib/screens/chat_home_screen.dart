import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'gene_ai_results_list_screen.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  UserModel? _currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentUser = ModalRoute.of(context)?.settings.arguments as UserModel?;
  }

  Future<void> _logout() async {
    await ApiService.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: colorScheme.primary),
            onPressed: _logout,
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 인사 메시지
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요,',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentUser?.name ?? '사용자'}님',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 타이틀
            Text(
              '무엇이 궁금하신가요?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),

            // 서비스 카드 목록
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _buildServiceCard(
                    title: '유전자 결과',
                    emoji: '🧬',
                    onTap: () {
                      if (_currentUser?.uuid != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GeneAIResultsListScreen(
                              patientUuid: _currentUser!.uuid!,
                              patientDisplayName: _currentUser!.name,
                            ),
                          ),
                        );
                      } else {
                        _showSnackBar('UUID가 없습니다.');
                      }
                    },
                    isEnabled: true,
                  ),
                  _buildServiceCard(
                    title: '항산화 결과',
                    emoji: '🛡️',
                    onTap: () {
                      _showSnackBar('아직 준비 중입니다.');
                    },
                    isEnabled: false,
                  ),
                  _buildServiceCard(
                    title: '합병증 결과',
                    emoji: '💥',
                    onTap: () {
                      _showSnackBar('아직 준비 중입니다.');
                    },
                    isEnabled: false,
                  ),
                  _buildServiceCard(
                    title: '영상 결과',
                    emoji: '🖼️',
                    onTap: () {
                      _showSnackBar('아직 준비 중입니다.');
                    },
                    isEnabled: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String emoji,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled ? colorScheme.primary.withOpacity(0.4) : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: isEnabled
              ? [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 44),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isEnabled ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}



