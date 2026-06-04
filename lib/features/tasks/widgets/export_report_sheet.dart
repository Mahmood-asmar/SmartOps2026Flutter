import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_button.dart';

class ExportReportSheet extends StatefulWidget {
  const ExportReportSheet({super.key});

  @override
  State<ExportReportSheet> createState() => _ExportReportSheetState();
}

class _ExportReportSheetState extends State<ExportReportSheet> {
  String selectedFormat = 'PDF';

  bool completedTasks = true;
  bool pendingTasks = true;
  bool inProgressTasks = false;
  bool employeePerformance = true;
  bool projectDeadlines = true;
  bool priorityDistribution = false;

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHeader(
            title: 'Export Reports',
            subtitle: 'Generate and export project and task performance reports.',
          ),

          const SizedBox(height: 20),

          const _DropdownBox(
            label: 'Report Type',
            value: 'Task Report',
          ),

          const SizedBox(height: 14),

          const _DropdownBox(
            label: 'Project Selection',
            value: 'All Projects',
          ),

          const SizedBox(height: 14),

          const Text(
            'DATE RANGE',
            style: TextStyle(
              color: Color(0xFF253B56),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: const [
              Expanded(
                child: _DateBox(text: 'mm/dd/yyyy'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _DateBox(text: 'mm/dd/yyyy'),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'REPORT FORMAT',
            style: TextStyle(
              color: Color(0xFF253B56),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

          _FormatOption(
            title: 'Adobe PDF',
            subtitle: 'Best for presentations',
            icon: Icons.picture_as_pdf_outlined,
            color: Colors.red,
            isSelected: selectedFormat == 'PDF',
            onTap: () {
              setState(() {
                selectedFormat = 'PDF';
              });
            },
           
          ),

          const SizedBox(height: 10),

          _FormatOption(
            title: 'Excel Spreadsheet',
            subtitle: 'Best for data analysis',
            icon: Icons.table_chart_outlined,
            color: Colors.green,
            isSelected: selectedFormat == 'Excel',
            onTap: () {
              setState(() {
                selectedFormat = 'Excel';
              });
            },
          ),

          const SizedBox(height: 18),

          const Text(
            'INCLUDED STATISTICS',
            style: TextStyle(
              color: Color(0xFF253B56),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          _CheckRow(
            title: 'Completed Tasks',
            value: completedTasks,
            onChanged: (value) {
              setState(() {
                completedTasks = value ?? false;
              });
            },
          ),

          _CheckRow(
            title: 'Pending Tasks',
            value: pendingTasks,
            onChanged: (value) {
              setState(() {
                pendingTasks = value ?? false;
              });
            },
          ),

          _CheckRow(
            title: 'In Progress Tasks',
            value: inProgressTasks,
            onChanged: (value) {
              setState(() {
                inProgressTasks = value ?? false;
              });
            },
          ),

          _CheckRow(
            title: 'Employee Performance',
            value: employeePerformance,
            onChanged: (value) {
              setState(() {
                employeePerformance = value ?? false;
              });
            },
          ),

          _CheckRow(
            title: 'Project Deadlines',
            value: projectDeadlines,
            onChanged: (value) {
              setState(() {
                projectDeadlines = value ?? false;
              });
            },
          ),

          _CheckRow(
            title: 'Priority Distribution',
            value: priorityDistribution,
            onChanged: (value) {
              setState(() {
                priorityDistribution = value ?? false;
              });
            },
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LIVE EXPORT PREVIEW',
                  style: TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                      child: _PreviewMetric(
                        value: '1,248',
                        label: 'Tasks Analyzed',
                      ),
                    ),
                    Expanded(
                      child: _PreviewMetric(
                        value: '94%',
                        label: 'Completion Rate',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(
                      child: _PreviewMetric(
                        value: '12',
                        label: 'Projects',
                      ),
                    ),
                    Expanded(
                      child: _PreviewMetric(
                        value: '82',
                        label: 'Hours Reported',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          AppButton(
            text: 'Generate Report',
            icon: Icons.download_outlined,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$selectedFormat report generated successfully'),
                ),
              );
            },
          ),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Center(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0B2E59),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HISTORICAL DATA',
                  style: TextStyle(
                    color: Color(0xFFBFD4EA),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 14),
                _HistoryRow(label: 'Reports Generated', value: '156'),
                SizedBox(height: 10),
                _HistoryRow(label: 'Active Projects', value: '24'),
                SizedBox(height: 10),
                _HistoryRow(label: 'Completion Rate', value: '88.4%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  final Widget child;

  const _SheetContainer({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: child,
          ),
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SheetHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE6EEF8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Color(0xFF0B2E59),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0B2E59),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final String label;
  final String value;

  const _DropdownBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF253B56),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EBEF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF667085),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  final String text;

  const _DateBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EBEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF667085),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF98A2B3),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0B2E59),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF0B2E59),
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0B2E59),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  final String value;
  final String label;

  const _PreviewMetric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0B2E59),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFBFD4EA),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}