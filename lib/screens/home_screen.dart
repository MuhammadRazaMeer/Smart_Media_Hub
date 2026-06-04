import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_media_hub/theme/app_colors.dart';
import 'package:smart_media_hub/widgets/app_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildSearchBar(context),
          const SizedBox(height: 32),
          if (_searchQuery.isEmpty) ...[
            _buildSectionHeading(context, "AI-Powered Features", Icons.bolt),
            const SizedBox(height: 12),
            _buildAIFeatures(context),
            const SizedBox(height: 32),
            _buildSectionHeading(context, "Quick Tools", Icons.grid_view_rounded),
            const SizedBox(height: 12),
            _buildQuickTools(context),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeading(context, "Recent Files", Icons.access_time_rounded),
                TextButton(onPressed: () => context.go('/history'), child: const Text("View All")),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecentFiles(context),
          ] else
            _buildSearchResults(context),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final tools = [
      {'title': 'Image Processing', 'icon': Icons.image, 'color': AppColors.purplePrimary, 'route': '/tools'},
      {'title': 'Video Tools', 'icon': Icons.videocam, 'color': AppColors.blue, 'route': '/video-tools'},
      {'title': 'GIF Maker', 'icon': Icons.gif_box, 'color': AppColors.green, 'route': '/gif-maker'},
      {'title': 'File Converter', 'icon': Icons.swap_horiz, 'color': AppColors.orange, 'route': '/file-converter'},
      {'title': 'AI HD Enhancement', 'icon': Icons.auto_fix_high_rounded, 'color': AppColors.pink, 'route': '/ai-enhancement'},
      {'title': 'Smart Automation', 'icon': Icons.settings_suggest_rounded, 'color': AppColors.cyan, 'route': '/auto'},
    ];

    final filtered = tools.where((t) => (t['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text("No tools found for '$_searchQuery'", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.65,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildToolCard(
          context,
          item['title'] as String,
          item['icon'] as IconData,
          item['color'] as Color,
          () => context.push(item['route'] as String),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back 👋", style: Theme.of(context).textTheme.displayLarge),
            Text("Ready to create today?", style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
        decoration: InputDecoration(
          icon: const Icon(Icons.search),
          hintText: "Search your tools...",
          hintStyle: Theme.of(context).textTheme.labelSmall,
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = "")) 
            : null,
        ),
      ),
    );
  }

  Widget _buildSectionHeading(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.purplePrimary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }

  Widget _buildAIFeatures(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFeatureCard(
            context,
            "AI HD Enhancement",
            Icons.auto_fix_high_rounded,
            AppColors.purplePink,
            () => context.push('/ai-enhancement'),
          ),
          const SizedBox(width: 12),
          _buildFeatureCard(
            context,
            "Smart Automation",
            Icons.settings_suggest_rounded,
            AppColors.blueCyan,
            () => context.go('/auto'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, Gradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        gradient: gradient,
        child: SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTools(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: [
        _buildToolCard(context, "Image Processing", Icons.image, AppColors.purplePrimary, () => context.go('/tools')),
        _buildToolCard(context, "Video Tools", Icons.videocam, AppColors.blue, () => context.push('/video-tools')),
        _buildToolCard(context, "GIF Maker", Icons.gif_box, AppColors.green, () => context.push('/gif-maker')),
        _buildToolCard(context, "File Converter", Icons.swap_horiz, AppColors.orange, () => context.push('/file-converter')),
      ],
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFiles(BuildContext context) {
    return Column(
      children: [
        _buildRecentItem(context, "Poster_Design.png", "Image", "2m ago", AppColors.purpleBlue),
        const SizedBox(height: 12),
        _buildRecentItem(context, "Promo_Video.mp4", "Video", "15m ago", AppColors.blueCyan),
        const SizedBox(height: 12),
        _buildRecentItem(context, "Reaction.gif", "GIF", "1h ago", AppColors.greenBlue),
      ],
    );
  }

  Widget _buildRecentItem(BuildContext context, String name, String type, String time, Gradient gradient) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.file_present_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                Text("$type • $time", style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
