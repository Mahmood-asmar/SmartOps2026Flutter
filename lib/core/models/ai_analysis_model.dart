class AiAnalysisModel {
  final int analysisId;
  final int projectId;
  final String projectName;
  final int healthScore;
  final String riskLevel;
  final String delayPrediction;
  final String summary;
  final List<String> recommendations;
  final List<AiBottleneckModel> bottlenecks;
  final AiMetricsModel metrics;
  final String? analyzedAt;

  AiAnalysisModel({
    required this.analysisId,
    required this.projectId,
    required this.projectName,
    required this.healthScore,
    required this.riskLevel,
    required this.delayPrediction,
    required this.summary,
    required this.recommendations,
    required this.bottlenecks,
    required this.metrics,
    this.analyzedAt,
  });

  factory AiAnalysisModel.fromJson(Map<String, dynamic> json) {
    final recommendationsData = json['recommendations'];
    final bottlenecksData = json['bottlenecks'];
    final metricsData = json['metrics'];

    return AiAnalysisModel(
      analysisId: _toInt(json['analysis_id'] ?? json['id']) ?? 0,
      projectId: _toInt(json['project_id'] ?? json['projectId']) ?? 0,
      projectName: json['project_name']?.toString() ??
          json['projectName']?.toString() ??
          'Project',
      healthScore: _toInt(json['health_score'] ?? json['healthScore']) ?? 0,
      riskLevel: json['risk_level']?.toString() ??
          json['riskLevel']?.toString() ??
          'medium',
      delayPrediction: json['delay_prediction']?.toString() ??
          json['delayPrediction']?.toString() ??
          'No prediction available.',
      summary: json['summary']?.toString() ?? 'No AI summary available.',
      recommendations: _parseStringList(recommendationsData),
      bottlenecks: _parseBottlenecks(bottlenecksData),
      metrics: AiMetricsModel.fromJson(
        metricsData is Map<String, dynamic>
            ? metricsData
            : <String, dynamic>{},
      ),
      analyzedAt:
      json['analyzed_at']?.toString() ?? json['analyzedAt']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return [];
  }

  static List<AiBottleneckModel> _parseBottlenecks(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => AiBottleneckModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }

    return [];
  }
}

class AiBottleneckModel {
  final int taskId;
  final String title;
  final String status;
  final String priority;
  final String? deadline;
  final String reason;

  AiBottleneckModel({
    required this.taskId,
    required this.title,
    required this.status,
    required this.priority,
    this.deadline,
    required this.reason,
  });

  factory AiBottleneckModel.fromJson(Map<String, dynamic> json) {
    return AiBottleneckModel(
      taskId: AiAnalysisModel._toInt(json['task_id'] ?? json['taskId']) ?? 0,
      title: json['title']?.toString() ?? 'Untitled Task',
      status: json['status']?.toString() ?? 'pending',
      priority: json['priority']?.toString() ?? 'medium',
      deadline: json['deadline']?.toString(),
      reason: json['reason']?.toString() ?? 'Potential bottleneck detected.',
    );
  }
}

class AiMetricsModel {
  final int? daysLeft;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int pendingTasks;
  final int overdueTasks;
  final int highPriorityTasks;
  final int highPriorityPendingTasks;
  final int completionRate;

  AiMetricsModel({
    this.daysLeft,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.highPriorityTasks,
    required this.highPriorityPendingTasks,
    required this.completionRate,
  });

  factory AiMetricsModel.fromJson(Map<String, dynamic> json) {
    return AiMetricsModel(
      daysLeft: AiAnalysisModel._toInt(json['days_left'] ?? json['daysLeft']),
      totalTasks: AiAnalysisModel._toInt(
        json['total_tasks'] ?? json['totalTasks'],
      ) ??
          0,
      completedTasks: AiAnalysisModel._toInt(
        json['completed_tasks'] ?? json['completedTasks'],
      ) ??
          0,
      inProgressTasks: AiAnalysisModel._toInt(
        json['in_progress_tasks'] ?? json['inProgressTasks'],
      ) ??
          0,
      pendingTasks: AiAnalysisModel._toInt(
        json['pending_tasks'] ?? json['pendingTasks'],
      ) ??
          0,
      overdueTasks: AiAnalysisModel._toInt(
        json['overdue_tasks'] ?? json['overdueTasks'],
      ) ??
          0,
      highPriorityTasks: AiAnalysisModel._toInt(
        json['high_priority_tasks'] ?? json['highPriorityTasks'],
      ) ??
          0,
      highPriorityPendingTasks: AiAnalysisModel._toInt(
        json['high_priority_pending_tasks'] ??
            json['highPriorityPendingTasks'],
      ) ??
          0,
      completionRate: AiAnalysisModel._toInt(
        json['completion_rate'] ?? json['completionRate'],
      ) ??
          0,
    );
  }
}