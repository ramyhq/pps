import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'sidebar.dart';
import 'header.dart';

class ScaffoldWithSidebar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithSidebar({required this.child, super.key});

  @override
  State<ScaffoldWithSidebar> createState() => _ScaffoldWithSidebarState();
}

class _ScaffoldWithSidebarState extends State<ScaffoldWithSidebar> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarExpanded = true;
  static const String _logoAssetPath = 'assets/images/sahl_logo.jpg';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppBreakpoints.shellMobile;

        if (isMobile) {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.light,
            drawer: Drawer(
              elevation: AppElevations.menu,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  width: AppWidths.sidebar,
                  child: Sidebar(
                    isExpanded: true,
                    showToggleButton: false,
                    onItemSelected: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Header(
                    onMenuPressed: () =>
                        _scaffoldKey.currentState?.openDrawer(),
                    showLogo: false,
                  ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.light,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Header(
                  showMenuButton: false,
                  showLogo: true,
                  logoAssetPath: _logoAssetPath,
                  sidebarExpanded: _isSidebarExpanded,
                  onSidebarToggle: () {
                    setState(() {
                      _isSidebarExpanded = !_isSidebarExpanded;
                    });
                  },
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isSidebarExpanded)
                        Sidebar(
                          isExpanded: true,
                          showToggleButton: false,
                          showHeader: false,
                        ),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
