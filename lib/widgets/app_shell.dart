import 'package:flutter/material.dart';
import 'app_sidebar.dart';
import '../theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppShell({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        drawer: SizedBox(
          width: 280,
          child: Drawer(
            backgroundColor: AppTheme.surfaceColor,
            child: AppSidebar(currentPath: currentPath),
          ),
        ),
        appBar: AppBar(
          backgroundColor: AppTheme.surfaceColor,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'SesMetin Admin',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        body: child,
      );
    }

    // Tablet ve Desktop için
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sabit sidebar - tablet ve desktop'ta görünür
          AppSidebar(currentPath: currentPath),
          // Scroll edilebilir içerik alanı
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

