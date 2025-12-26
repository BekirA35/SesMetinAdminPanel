import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class AppSidebar extends StatefulWidget {
  final String currentPath;

  const AppSidebar({super.key, required this.currentPath});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          right: BorderSide(
            color: AppTheme.cardColor.withAlpha(128),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildLogo(),
          const SizedBox(height: 40),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    path: '/',
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.people_rounded,
                    label: 'Kullanıcılar',
                    path: '/users',
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.history_rounded,
                    label: 'Aktiviteler',
                    path: '/activities',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildBottomSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Center(
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withAlpha(102),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String path,
  }) {
    final isActive = _isActivePath(path);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(path),
        borderRadius: BorderRadius.circular(14),
        child: Tooltip(
          message: label,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor.withAlpha(38) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? AppTheme.primaryColor.withAlpha(77) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryColor.withAlpha(51) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isActive ? AppTheme.primaryColor : AppTheme.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isActivePath(String path) {
    if (path == '/') {
      return widget.currentPath == '/' || widget.currentPath == '/dashboard';
    }
    return widget.currentPath.startsWith(path);
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await AuthService.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Tooltip(
              message: 'Çıkış Yap',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withAlpha(38),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 22,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
