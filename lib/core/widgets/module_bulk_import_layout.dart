import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pps/core/constants/app_colors.dart';

class ModuleBulkImportLayout extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDownloadTemplate;
  final VoidCallback onUploadData;
  final List<String> logs;
  final bool isUploading;

  const ModuleBulkImportLayout({
    super.key,
    required this.title,
    required this.description,
    required this.onDownloadTemplate,
    required this.onUploadData,
    required this.logs,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 700;
              if (isDesktop) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [_buildTitleSection(), _buildActionsRow()],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(),
                    const SizedBox(height: 16),
                    _buildActionsRow(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),

          // Terminal Section
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Dark background for terminal
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Terminal Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTerminalDot(Colors.red),
                      const SizedBox(width: 8),
                      _buildTerminalDot(Colors.orange),
                      const SizedBox(width: 8),
                      _buildTerminalDot(Colors.green),
                      const SizedBox(width: 16),
                      const Text(
                        "Import Terminal",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: logs.isEmpty
                            ? null
                            : () async {
                                await Clipboard.setData(
                                  ClipboardData(text: logs.join('\n')),
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Logs copied'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: Colors.white70,
                        ),
                        tooltip: 'Copy logs',
                      ),
                    ],
                  ),
                ),
                // Terminal Body
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length + (isUploading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isUploading && index == logs.length) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Text(
                                "> ",
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Processing...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final log = logs[index];
                      final normalized = log.trimLeft();
                      Color logColor;
                      if (normalized.startsWith('[Error]') ||
                          normalized.startsWith('[Failed]') ||
                          normalized.startsWith('[خطأ]') ||
                          normalized.startsWith('[فشل]')) {
                        logColor = Colors.red.shade300;
                      } else if (normalized.startsWith('[Success]') ||
                          normalized.startsWith('[Completed]') ||
                          normalized.startsWith('[نجاح]') ||
                          normalized.startsWith('[تم]')) {
                        logColor = Colors.greenAccent;
                      } else if (normalized.startsWith('[Inserted]')) {
                        logColor = Colors.greenAccent;
                      } else if (normalized.startsWith('[Updated]')) {
                        logColor = Colors.lightBlueAccent;
                      } else if (normalized.startsWith('[Skipped]')) {
                        logColor = Colors.amberAccent;
                      } else if (normalized.startsWith('[Warning]') ||
                          normalized.startsWith('[تحذير]')) {
                        logColor = Colors.orangeAccent;
                      } else if (normalized.startsWith('[Process]')) {
                        logColor = Colors.lightBlueAccent;
                      } else if (normalized.startsWith('[System]') ||
                          normalized.startsWith('[System|')) {
                        logColor = Colors.white70;
                      } else {
                        logColor = Colors.white;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "> ",
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                log,
                                style: TextStyle(
                                  color: logColor,
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton(
          title: "Download Template",
          icon: Icons.download_rounded,
          color: AppColors.primary,
          onTap: onDownloadTemplate,
        ),
        _buildActionButton(
          title: "Upload Data",
          icon: Icons.upload_file_rounded,
          color: const Color(0xFF10B981), // Green
          onTap: onUploadData,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: color.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
