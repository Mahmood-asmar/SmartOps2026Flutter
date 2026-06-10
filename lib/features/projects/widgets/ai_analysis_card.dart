import 'package:flutter/material.dart';
import 'package:smartops/core/models/ai_analysis_model.dart';

class AiAnalysisCard extends StatelessWidget {
  final AiAnalysisModel? analysis;
  final bool isLoading;
  final bool isGenerating;
  final String errorMessage;
  final VoidCallback onGenerate;
  final VoidCallback onRefresh;

  const AiAnalysisCard({
    super.key,
    required this.analysis,
    required this.isLoading,
    required this.isGenerating,
    required this.errorMessage,
    required this.onGenerate,
    required this.onRefresh,
  });

  Color get _riskColor {
    final risk = analysis?.riskLevel ?? 'medium';

    if (risk == 'low') return Colors.green.shade700;
    if (risk == 'medium') return Colors.orange.shade700;
    if (risk == 'critical') return Colors.red.shade900;

    return Colors.red.shade700;
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    })
        .join(' ');
  }

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not analyzed yet';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final item = analysis;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF071F3A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF071F3A).withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                if (isLoading)
                  _buildLoading()
                else if (item == null)
                  _buildEmptyState()
                else
                  _buildAnalysisContent(item),
                if (errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildError(),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: isGenerating || isLoading
                              ? null
                              : onGenerate,
                          icon: isGenerating
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.auto_awesome, size: 18),
                          label: Text(
                            isGenerating ? 'Generating...' : 'Generate AI',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.blueGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: isGenerating || isLoading ? null : onRefresh,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (item != null) _buildBottomDetails(item),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: const Icon(
            Icons.psychology_alt_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI HEALTH ANALYSIS',
                style: TextStyle(
                  color: Color(0xFFBFD4EA),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'SmartOps Project Health Engine',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Loading AI analysis...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No AI analysis generated yet.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Generate a smart project analysis to calculate health score, risk level, delay prediction, bottlenecks, and recommended actions.',
            style: TextStyle(
              color: Color(0xFFD8E3F0),
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent(AiAnalysisModel item) {
    final healthValue = item.healthScore.clamp(0, 100) / 100;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 92,
                      height: 92,
                      child: CircularProgressIndicator(
                        value: healthValue,
                        strokeWidth: 9,
                        color: _riskColor,
                        backgroundColor: const Color(0xFFE4E7EC),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${item.healthScore}',
                          style: const TextStyle(
                            color: Color(0xFF0B2E59),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          '/100',
                          style: TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health Score',
                      style: TextStyle(
                        color: Color(0xFF98A2B3),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _MiniBadge(
                      label: _formatLabel(item.riskLevel),
                      color: _riskColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.delayPrediction,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SMART SUMMARY',
                style: TextStyle(
                  color: Color(0xFFBFD4EA),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.summary,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Last analyzed: ${_formatDate(item.analyzedAt)}',
                style: const TextStyle(
                  color: Color(0xFFBFD4EA),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomDetails(AiAnalysisModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetrics(item.metrics),
          const SizedBox(height: 18),
          const Text(
            'RECOMMENDED ACTIONS',
            style: TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          if (item.recommendations.isEmpty)
            const _EmptyMiniText(text: 'No recommendations available.')
          else
            ...item.recommendations.asMap().entries.map(
                  (entry) => _ActionItem(
                index: entry.key + 1,
                text: entry.value,
              ),
            ),
          const SizedBox(height: 18),
          const Text(
            'BOTTLENECK DETECTION',
            style: TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          if (item.bottlenecks.isEmpty)
            const _EmptyMiniText(text: 'No major bottlenecks detected.')
          else
            ...item.bottlenecks.map(
                  (task) => _BottleneckItem(
                task: task,
                formatLabel: _formatLabel,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetrics(AiMetricsModel metrics) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.8,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _MetricBox(
          title: 'Completion',
          value: '${metrics.completionRate}%',
          icon: Icons.task_alt_outlined,
        ),
        _MetricBox(
          title: 'Pending',
          value: metrics.pendingTasks.toString(),
          icon: Icons.pending_actions_outlined,
        ),
        _MetricBox(
          title: 'Overdue',
          value: metrics.overdueTasks.toString(),
          icon: Icons.warning_amber_rounded,
        ),
        _MetricBox(
          title: 'High Risk',
          value: metrics.highPriorityPendingTasks.toString(),
          icon: Icons.priority_high_rounded,
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        errorMessage,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE9EEF5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF0B2E59),
            size: 22,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final int index;
  final String text;

  const _ActionItem({
    required this.index,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE9EEF5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: const Color(0xFF0B2E59),
            child: Text(
              index.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottleneckItem extends StatelessWidget {
  final AiBottleneckModel task;
  final String Function(String value) formatLabel;

  const _BottleneckItem({
    required this.task,
    required this.formatLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isHigh = task.priority == 'high';

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE9EEF5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            task.reason,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 11,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _SmallTag(
                text: formatLabel(task.status),
                color: Colors.blueGrey.shade700,
              ),
              _SmallTag(
                text: formatLabel(task.priority),
                color: isHigh ? Colors.red.shade700 : Colors.orange.shade700,
              ),
              if (task.deadline != null)
                _SmallTag(
                  text: task.deadline!,
                  color: Colors.grey.shade700,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String text;
  final Color color;

  const _SmallTag({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyMiniText extends StatelessWidget {
  final String text;

  const _EmptyMiniText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE9EEF5),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF98A2B3),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}