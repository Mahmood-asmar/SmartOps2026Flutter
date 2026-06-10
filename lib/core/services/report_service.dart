import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as excel_package;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:smartops/core/models/task_model.dart';

class ReportService {
  static Future<void> generatePdfReport({
    required String reportType,
    required String reportFormat,
    required String projectLabel,
    required String dateRange,
    required List<TaskModel> tasks,
    required int totalTasks,
    required int completedCount,
    required int pendingCount,
    required int inProgressCount,
    required int overdueCount,
    required int highPriorityCount,
    required int mediumPriorityCount,
    required int lowPriorityCount,
    required int completionRate,
    required int projectsCount,
    required int employeesCount,
  }) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    final generatedAt =
        '${now.year}-${_two(now.month)}-${_two(now.day)} ${_two(now.hour)}:${_two(now.minute)}';

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(
            base: await PdfGoogleFonts.robotoRegular(),
            bold: await PdfGoogleFonts.robotoBold(),
          ),
        ),
        build: (context) {
          return [
            _buildHeader(
              title: 'SmartOps Report',
              reportType: reportType,
              generatedAt: generatedAt,
            ),

            pw.SizedBox(height: 18),

            _buildInfoGrid(
              projectLabel: projectLabel,
              dateRange: dateRange,
              reportFormat: reportFormat,
            ),

            pw.SizedBox(height: 18),

            _buildSummarySection(
              totalTasks: totalTasks,
              completionRate: completionRate,
              projectsCount: projectsCount,
              employeesCount: employeesCount,
            ),

            pw.SizedBox(height: 18),

            _buildStatusAndPrioritySection(
              completedCount: completedCount,
              pendingCount: pendingCount,
              inProgressCount: inProgressCount,
              overdueCount: overdueCount,
              highPriorityCount: highPriorityCount,
              mediumPriorityCount: mediumPriorityCount,
              lowPriorityCount: lowPriorityCount,
            ),

            pw.SizedBox(height: 20),

            _buildTasksTable(tasks),

            pw.SizedBox(height: 18),

            _buildFooter(),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: _buildFileName(reportType, 'pdf'),
    );
  }

  static Future<void> generateExcelReport({
    required String reportType,
    required String projectLabel,
    required String dateRange,
    required List<TaskModel> tasks,
    required int totalTasks,
    required int completedCount,
    required int pendingCount,
    required int inProgressCount,
    required int overdueCount,
    required int highPriorityCount,
    required int mediumPriorityCount,
    required int lowPriorityCount,
    required int completionRate,
    required int projectsCount,
    required int employeesCount,
  }) async {
    final book = excel_package.Excel.createExcel();

    final summarySheet = book['Summary'];
    final tasksSheet = book['Tasks'];

    book.delete('Sheet1');

    summarySheet.appendRow([
      excel_package.TextCellValue('SmartOps Report'),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Report Type'),
      excel_package.TextCellValue(reportType),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Project'),
      excel_package.TextCellValue(projectLabel),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Date Range'),
      excel_package.TextCellValue(dateRange),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Total Tasks'),
      excel_package.IntCellValue(totalTasks),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Completion Rate'),
      excel_package.TextCellValue('$completionRate%'),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Projects'),
      excel_package.IntCellValue(projectsCount),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Employees'),
      excel_package.IntCellValue(employeesCount),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Completed'),
      excel_package.IntCellValue(completedCount),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Pending'),
      excel_package.IntCellValue(pendingCount),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('In Progress'),
      excel_package.IntCellValue(inProgressCount),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Overdue'),
      excel_package.IntCellValue(overdueCount),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('High Priority'),
      excel_package.IntCellValue(highPriorityCount),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Medium Priority'),
      excel_package.IntCellValue(mediumPriorityCount),
    ]);

    summarySheet.appendRow([
      excel_package.TextCellValue('Low Priority'),
      excel_package.IntCellValue(lowPriorityCount),
    ]);

    tasksSheet.appendRow([
      excel_package.TextCellValue('Task ID'),
      excel_package.TextCellValue('Title'),
      excel_package.TextCellValue('Project'),
      excel_package.TextCellValue('Employee'),
      excel_package.TextCellValue('Status'),
      excel_package.TextCellValue('Priority'),
      excel_package.TextCellValue('Deadline'),
      excel_package.TextCellValue('Description'),
    ]);

    for (final task in tasks) {
      tasksSheet.appendRow([
        excel_package.IntCellValue(task.taskId),
        excel_package.TextCellValue(task.title),
        excel_package.TextCellValue(task.projectName ?? 'Unknown Project'),
        excel_package.TextCellValue(
          task.assignedUserName ??
              task.assignedUserEmail ??
              'Unassigned',
        ),
        excel_package.TextCellValue(task.status.replaceAll('_', ' ')),
        excel_package.TextCellValue(task.priority),
        excel_package.TextCellValue(task.deadline ?? 'No deadline'),
        excel_package.TextCellValue(task.description),
      ]);
    }

    final bytes = book.encode();

    if (bytes == null) {
      throw Exception('Failed to generate Excel report.');
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${_buildFileName(reportType, 'xlsx')}');

    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'SmartOps $reportType',
    );
  }

  static pw.Widget _buildHeader({
    required String title,
    required String reportType,
    required String generatedAt,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#0B2E59'),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 42,
            height: 42,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#E6EEF8'),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              'S',
              style: pw.TextStyle(
                color: PdfColor.fromHex('#0B2E59'),
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  reportType,
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#BFD4EA'),
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.Text(
            generatedAt,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#BFD4EA'),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoGrid({
    required String projectLabel,
    required String dateRange,
    required String reportFormat,
  }) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: _infoCard(
            label: 'Project',
            value: projectLabel,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _infoCard(
            label: 'Date Range',
            value: dateRange,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _infoCard(
            label: 'Format',
            value: reportFormat,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummarySection({
    required int totalTasks,
    required int completionRate,
    required int projectsCount,
    required int employeesCount,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F5F7FA'),
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: PdfColor.fromHex('#E4E7EC')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Executive Summary'),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: _metricCard(
                  label: 'Tasks',
                  value: '$totalTasks',
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _metricCard(
                  label: 'Completion',
                  value: '$completionRate%',
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _metricCard(
                  label: 'Projects',
                  value: '$projectsCount',
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _metricCard(
                  label: 'Employees',
                  value: '$employeesCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatusAndPrioritySection({
    required int completedCount,
    required int pendingCount,
    required int inProgressCount,
    required int overdueCount,
    required int highPriorityCount,
    required int mediumPriorityCount,
    required int lowPriorityCount,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('Status Overview'),
                pw.SizedBox(height: 10),
                _detailRow('Completed', completedCount.toString()),
                _detailRow('Pending', pendingCount.toString()),
                _detailRow('In Progress', inProgressCount.toString()),
                _detailRow('Overdue', overdueCount.toString()),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _sectionTitle('Priority Distribution'),
                pw.SizedBox(height: 10),
                _detailRow('High', highPriorityCount.toString()),
                _detailRow('Medium', mediumPriorityCount.toString()),
                _detailRow('Low', lowPriorityCount.toString()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTasksTable(List<TaskModel> tasks) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('Task Details'),
          pw.SizedBox(height: 12),
          if (tasks.isEmpty)
            pw.Text(
              'No tasks found for the selected filters.',
              style: pw.TextStyle(
                color: PdfColor.fromHex('#667085'),
                fontSize: 11,
              ),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: [
                'Task',
                'Project',
                'Employee',
                'Status',
                'Priority',
                'Deadline',
              ],
              data: tasks.map((task) {
                return [
                  task.title,
                  task.projectName ?? 'Unknown',
                  task.assignedUserName ??
                      task.assignedUserEmail ??
                      'Unassigned',
                  task.status.replaceAll('_', ' '),
                  task.priority,
                  task.deadline ?? '-',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#0B2E59'),
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 8,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 6,
              ),
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('#E4E7EC'),
                width: 0.5,
              ),
              oddRowDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F9FAFB'),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(
            color: PdfColors.grey300,
            width: 0.8,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'SmartOps Architectural Systems',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#667085'),
              fontSize: 9,
            ),
          ),
          pw.Text(
            'Generated by SmartOps',
            style: pw.TextStyle(
              color: PdfColor.fromHex('#667085'),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoCard({
    required String label,
    required String value,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label.toUpperCase(),
            style: pw.TextStyle(
              color: PdfColor.fromHex('#98A2B3'),
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            maxLines: 2,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#0B2E59'),
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _metricCard({
    required String label,
    required String value,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex('#E4E7EC')),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#0B2E59'),
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label.toUpperCase(),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#98A2B3'),
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _detailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#667085'),
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Spacer(),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: PdfColor.fromHex('#0B2E59'),
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        color: PdfColor.fromHex('#0B2E59'),
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  static pw.BoxDecoration _cardDecoration() {
    return pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: pw.BorderRadius.circular(12),
      border: pw.Border.all(color: PdfColor.fromHex('#E4E7EC')),
    );
  }

  static String _two(int value) {
    return value.toString().padLeft(2, '0');
  }

  static String _buildFileName(String reportType, String extension) {
    final cleanName = reportType
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('/', '_');

    final now = DateTime.now();

    return 'smartops_${cleanName}_${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}.$extension';
  }
}