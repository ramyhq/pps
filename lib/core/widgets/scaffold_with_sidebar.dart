import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'sidebar.dart';
import 'header.dart';

class ScaffoldWithSidebar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithSidebar({
    required this.child,
    super.key,
  });

  @override
  State<ScaffoldWithSidebar> createState() => _ScaffoldWithSidebarState();
}

class _ScaffoldWithSidebarState extends State<ScaffoldWithSidebar> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSidebarExpanded = true;

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
                  onMenuPressed: () {
                    setState(() {
                      _isSidebarExpanded = !_isSidebarExpanded;
                    });
                  },
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Sidebar(
                        isExpanded: _isSidebarExpanded,
                        onToggleExpanded: () {
                          setState(() {
                            _isSidebarExpanded = !_isSidebarExpanded;
                          });
                        },
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
