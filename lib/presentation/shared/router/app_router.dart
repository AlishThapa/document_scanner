import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/scanner/scanner_screen.dart';
import '../../screens/result/result_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/settings/legal_screen.dart';
import '../../../core/constants/legal_texts.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scanner',
        pageBuilder: (context, state) => _horizontalTransition(
          state.pageKey,
          const ScannerScreen(),
        ),
      ),
      GoRoute(
        path: '/result/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final isFromScanner = state.uri.queryParameters['fromScanner'] == 'true';
          return _horizontalTransition(
            state.pageKey,
            ResultScreen(scanId: id, isFromScanner: isFromScanner),
          );
        },
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) => _horizontalTransition(
          state.pageKey,
          const HistoryScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _horizontalTransition(
          state.pageKey,
          const SettingsScreen(),
        ),
        routes: [
          GoRoute(
            path: 'legal/:type',
            pageBuilder: (context, state) {
              final type = state.pathParameters['type'];
              final isTos = type == 'tos';
              return _horizontalTransition(
                state.pageKey,
                LegalScreen(
                  title: isTos ? 'Terms of Service' : 'Privacy Policy',
                  content: isTos ? LegalTexts.termsOfService : LegalTexts.privacyPolicy,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}

/// A standard horizontal transition used for all navigation.
/// Pushes from right-to-left, pops from left-to-right.
CustomTransitionPage _horizontalTransition(LocalKey key, Widget child) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // 1. The page entering/leaving via primary animation
      // When pushing: Slides from Right (1,0) to Center (0,0)
      // When popping: Slides from Center (0,0) to Right (1,0)
      final slideIn = animation.drive(
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      );

      // 2. The page leaving via secondary animation (being covered by another page)
      // When pushing next: Slides slightly Left (0,0) to (-0.3, 0)
      // When popping back: Slides from Left (-0.3, 0) back to Center (0,0)
      final slideOut = secondaryAnimation.drive(
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.3, 0.0),
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      );

      return SlideTransition(
        position: slideIn,
        child: SlideTransition(
          position: slideOut,
          child: child,
        ),
      );
    },
  );
}
