import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_shell.dart';
import '../widgets/safe_opacity.dart';
import '../pages/dashboard_page.dart';
import '../pages/users_page.dart';
import '../pages/user_detail_page.dart';
import '../pages/activities_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(
          currentPath: state.uri.path,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const DashboardPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SafeFadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/dashboard',
          redirect: (context, state) => '/',
        ),
        GoRoute(
          path: '/users',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const UsersPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SafeFadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/users/:userId',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return CustomTransitionPage(
              key: state.pageKey,
              child: UserDetailPage(userId: userId),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/activities',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ActivitiesPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SafeFadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0F172A),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 80,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 24),
          Text(
            '404',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white.withAlpha(230),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sayfa Bulunamadı',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withAlpha(153),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_rounded),
            label: const Text('Ana Sayfaya Dön'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    ),
  ),
);
