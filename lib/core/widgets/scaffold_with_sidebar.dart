import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'sidebar.dart';
import 'header.dart';

class ScaffoldWithSidebar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithSidebar({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar
          const Sidebar(),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Child (Screen Content)
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
