import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_media_hub/theme/theme_provider.dart';
import 'package:smart_media_hub/theme/app_colors.dart';
import 'package:smart_media_hub/widgets/app_card.dart';
import 'package:smart_media_hub/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("PREFERENCES"),
              const SizedBox(height: 12),
              _settingsToggle(
                context,
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                isDark ? "Dark Mode" : "Light Mode",
                isDark,
                (v) => themeProvider.toggleTheme(v),
              ),
              const SizedBox(height: 8),
              _settingsToggle(context, Icons.notifications_active_outlined, "Notifications", true, (v) {}),
              
              const SizedBox(height: 32),
              _buildSectionHeader("PRIVACY & SECURITY"),
              const SizedBox(height: 12),
              _settingsRow(context, Icons.lock_outline, "Privacy Settings"),
              const SizedBox(height: 8),
              _settingsRow(context, Icons.data_usage_rounded, "Data Management"),
              
              const SizedBox(height: 32),
              _buildSectionHeader("SUPPORT"),
              const SizedBox(height: 12),
              _settingsRow(context, Icons.help_outline_rounded, "Help Center"),
              
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () async {
                  await authService.signOut();
                  context.go('/auth');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.red),
                      const SizedBox(width: 12),
                      Text("Sign Out", style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Column(
                  children: [
                    Text("Version 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("© 2024 Smart Media Hub", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2),
    );
  }

  Widget _settingsToggle(BuildContext context, IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.purplePrimary),
        ],
      ),
    );
  }

  Widget _settingsRow(BuildContext context, IconData icon, String label) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
    );
  }
}
