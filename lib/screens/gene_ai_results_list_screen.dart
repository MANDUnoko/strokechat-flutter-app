import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';

class GeneAIResultsListScreen extends StatefulWidget {
  final String patientUuid;
  final String patientDisplayName;

  const GeneAIResultsListScreen({
    super.key,
    required this.patientUuid,
    required this.patientDisplayName,
  });

  @override
  State<GeneAIResultsListScreen> createState() => _GeneAIResultsListScreenState();
}

class _GeneAIResultsListScreenState extends State<GeneAIResultsListScreen> {
  late Future<List<GeneAIResult>?> _geneAIResultsFuture;

  @override
  void initState() {
    super.initState();
    _geneAIResultsFuture = ApiService.getGeneAIResultsForPatient(widget.patientUuid);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.patientDisplayName}님 결과',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<GeneAIResult>?>(
        future: _geneAIResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading(context);
          } else if (snapshot.hasError) {
            return _buildError(context);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmpty(context);
          } else {
            final results = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return _buildResultCard(context, results[index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child:_buildMessageScreen(
        icon: Icons.error_outline_rounded,
        title: '결과를 불러오는 데 실패했습니다.',
        subtitle: '다시 시도하거나 의료진에게 문의해주세요.',
        iconColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: _buildMessageScreen(
        icon: Icons.info_outline_rounded,
        title: '유전자 AI 결과가 없습니다.',
        subtitle: '추후 결과가 추가될 예정입니다.',
        iconColor: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildMessageScreen({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 60),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, GeneAIResult result) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isRisky = result.confidenceScore > 0.70;

    final Color cardColor = Colors.white;
    final Color borderColor = isRisky
        ? colorScheme.error
        : Colors.grey.shade300;
    final Color textColor = Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pushNamed(
            '/init-chat',
            arguments: {
              'patient_uuid': widget.patientUuid,
              'source_table': 'gene_ai_result',
              'source_id': result.id,
              'patient_display_name': widget.patientDisplayName,
              'result_overview':
                  '${result.modelName} (신뢰도: ${result.confidenceScore.toStringAsFixed(2)})',
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🧬 ${result.modelName}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '시행 날짜: ${result.formattedDate}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                result.resultText.length > 150
                    ? '${result.resultText.substring(0, 150)}...'
                    : result.resultText,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (isRisky)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 20, color: colorScheme.error),
                      const SizedBox(width: 6),
                      Text(
                        '주의: 뇌졸중 위험도 높음',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 26,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


