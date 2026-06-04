import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_media_hub/screens/splash_screen.dart';
import 'package:smart_media_hub/screens/auth_screen.dart';
import 'package:smart_media_hub/widgets/main_scaffold.dart';
import 'package:smart_media_hub/screens/home_screen.dart';
import 'package:smart_media_hub/screens/image_processing_screen.dart';
import 'package:smart_media_hub/screens/video_tools_screen.dart';
import 'package:smart_media_hub/screens/gif_maker_screen.dart';
import 'package:smart_media_hub/screens/ai_enhancement_screen.dart';
import 'package:smart_media_hub/screens/file_converter_screen.dart';
import 'package:smart_media_hub/screens/automation_screen.dart';
import 'package:smart_media_hub/screens/history_screen.dart';
import 'package:smart_media_hub/screens/profile_screen.dart';
import 'package:smart_media_hub/screens/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/tools',
            builder: (context, state) => const ImageProcessingScreen(),
          ),
          GoRoute(
            path: '/auto',
            builder: (context, state) => const AutomationScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/video-tools',
        builder: (context, state) => const VideoToolsScreen(),
      ),
      GoRoute(
        path: '/gif-maker',
        builder: (context, state) => const GifMakerScreen(),
      ),
      GoRoute(
        path: '/ai-enhancement',
        builder: (context, state) => const AiEnhancementScreen(),
      ),
      GoRoute(
        path: '/file-converter',
        builder: (context, state) => const FileConverterScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
