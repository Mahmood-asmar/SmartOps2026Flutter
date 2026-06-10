import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_button.dart';

class RejectionDialog extends StatefulWidget {
  final Future<void> Function(String reason) onConfirm;

  const RejectionDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<RejectionDialog> createState() => _RejectionDialogState();
}

class _RejectionDialogState extends State<RejectionDialog> {
  final TextEditingController controller = TextEditingController();
  bool isSubmitting = false;
  String errorMessage = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = controller.text.trim();

    if (reason.isEmpty) {
      setState(() {
        errorMessage = 'Rejection reason is required';
      });
      return;
    }

    if (reason.length < 2) {
      setState(() {
        errorMessage = 'Rejection reason must be at least 2 characters';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = '';
    });

    try {
      await widget.onConfirm(reason);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.cancel_outlined,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Reject Request',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Provide a clear reason so the client understands why the request was rejected.',
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write rejection reason...',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                errorText: errorMessage.isEmpty ? null : errorMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.red.shade600),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Confirm Rejection',
              icon: Icons.cancel_outlined,
              isLoading: isSubmitting,
              backgroundColor: Colors.red,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}