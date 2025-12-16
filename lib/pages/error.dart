import 'package:fl_clash/common/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InitErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace stack;

  const InitErrorScreen({super.key, required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Init Failed'),
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.report_problem,
                    color: colorScheme.error,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'The application encountered a critical error during startup and cannot continue.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionLabel('Error Details:'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.opacity50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.error.opacity50),
                ),
                child: SelectableText(
                  error.toString(),
                  style: TextStyle(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionLabel('Stack Trace:'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.opacity50),
                ),
                child: SelectableText(
                  stack.toString(),
                  style: const TextStyle(
                    fontFamily: 'monospace', // Makes code easier to read
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _copyToClipboard(context),
        label: const Text('Copy Details'),
        icon: const Icon(Icons.copy),
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final text = '=== ERROR ===\n$error\n\n=== STACK TRACE ===\n$stack';
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
