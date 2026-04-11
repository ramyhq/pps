import 'package:flutter/material.dart';
import 'package:pps/core/constants/app_colors.dart';

class ModuleDashboardLayout extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onViewList;
  final VoidCallback onAddSingle;
  final VoidCallback onAddBulk;
  final List<Widget> kpiCards;
  final Widget? extraContent;

  const ModuleDashboardLayout({
    super.key,
    required this.title,
    required this.description,
    required this.onViewList,
    required this.onAddSingle,
    required this.onAddBulk,
    this.kpiCards = const [],
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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

          // KPI Cards
          if (kpiCards.isNotEmpty) ...[
            Wrap(spacing: 16, runSpacing: 16, children: kpiCards),
            const SizedBox(height: 32),
          ],

          // Extra Content (Charts, Recent Activity, etc.)
          if (extraContent != null) extraContent!,
        ],
      ),
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
          title: "View All",
          icon: Icons.list_alt_rounded,
          color: AppColors.primary,
          onTap: onViewList,
        ),
        _buildActionButton(
          title: "Add",
          icon: Icons.add_rounded,
          color: const Color(0xFF10B981), // Green
          onTap: onAddSingle,
        ),
        _buildActionButton(
          title: "Add Bulk",
          icon: Icons.library_add_rounded,
          color: AppColors.info, // Purple
          onTap: onAddBulk,
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
