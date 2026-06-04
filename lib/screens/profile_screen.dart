import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_media_hub/theme/app_colors.dart';
import 'package:smart_media_hub/widgets/app_card.dart';
import 'package:smart_media_hub/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final name = user?.displayName ?? "User";
    final email = user?.email ?? "No Email";
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "U";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Profile", style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 24),
          _buildProfileCard(context, name, email, initials),
          const SizedBox(height: 32),
          _buildStatsRow(context),
          const SizedBox(height: 32),
          _buildMenu(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String name, String email, String initials) {
    return AppCard(
      gradient: AppColors.purpleBlue,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(
              child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                Text(email, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(30)),
                  child: const Text("Free Plan", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statCard(context, "1234", "Files", AppColors.purplePink)),
        const SizedBox(width: 12),
        Expanded(child: _statCard(context, "456", "AI En.", AppColors.blueCyan)),
        const SizedBox(width: 12),
        Expanded(child: _statCard(context, "2.4GB", "Storage", AppColors.greenBlue)),
      ],
    );
  }

  Widget _statCard(BuildContext context, String value, String label, Gradient gradient) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.data_usage, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [
        _menuItem(context, Icons.settings_outlined, "Account Settings", () => context.push('/settings')),
        const SizedBox(height: 12),
        _buildUpgradeCard(context),
        const SizedBox(height: 12),
        _menuItem(context, Icons.help_outline_rounded, "Help & Support", () {}),
      ],
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.purplePrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.purplePrimary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.purplePrimary, width: 2),
      ),
      child: AppCard(
        border: Border.all(color: Colors.transparent),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(gradient: AppColors.purplePink, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(child: Text("Upgrade to Pro", style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.purplePrimary))),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.purplePrimary),
          ],
        ),
      ),
    );
  }
}
