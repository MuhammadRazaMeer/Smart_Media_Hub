import 'package:flutter/material.dart';
import 'package:smart_media_hub/widgets/app_card.dart';
import 'package:smart_media_hub/theme/app_colors.dart';

class UploadArea extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String? subtitle;
  final double height;
  final Widget? preview;

  const UploadArea({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
    this.subtitle,
    this.height = 200,
    this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: preview ?? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppColors.purplePrimary),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
