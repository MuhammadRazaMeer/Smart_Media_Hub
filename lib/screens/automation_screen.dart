import 'package:flutter/material.dart';
import 'package:smart_media_hub/theme/app_colors.dart';
import 'package:smart_media_hub/widgets/app_card.dart';
import 'package:smart_media_hub/widgets/gradient_button.dart';
import 'package:go_router/go_router.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  final List<Map<String, dynamic>> _activeWorkflows = [
    {'name': 'Social Media Crop', 'steps': 3, 'lastRun': '2h ago', 'active': true},
    {'name': 'Archive Old Videos', 'steps': 2, 'lastRun': 'Yesterday', 'active': true},
    {'name': 'Daily AI Enhance', 'steps': 5, 'lastRun': '12m ago', 'active': true},
  ];

  void _runWorkflow(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Running workflow: ${_activeWorkflows[index]['name']}...")),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _activeWorkflows[index]['lastRun'] = 'Just now';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Workflow ${_activeWorkflows[index]['name']} completed successfully!")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Automation", style: Theme.of(context).textTheme.displayLarge),
          Text("Set up media workflows & pipelines", style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 24),
          _buildWorkflowBanner(context),
          const SizedBox(height: 32),
          Text("Templates", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _templateCard(context, "Image Processing", Icons.photo_filter, AppColors.purplePink, '/tools'),
                _templateCard(context, "Video Workflow", Icons.video_settings, AppColors.blueCyan, '/video-tools'),
                _templateCard(context, "AI Enhancement", Icons.auto_fix_high, AppColors.greenBlue, '/ai-enhancement'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Text("My Workflows", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(30)),
                child: Text("${_activeWorkflows.length} active", style: const TextStyle(color: AppColors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activeWorkflows.length,
            itemBuilder: (context, index) {
              final w = _activeWorkflows[index];
              return _workflowItem(context, index, w['name'], w['steps'], w['lastRun']);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowBanner(BuildContext context) {
    return AppCard(
      gradient: AppColors.purpleBlue,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Create Workflow", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                Text("Chain multiple tools together", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _templateCard(BuildContext context, String title, IconData icon, Gradient gradient, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        child: AppCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workflowItem(BuildContext context, int index, String name, int steps, String lastRun) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        borderRadius: 20,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleMedium),
                      Text("$steps steps • Last run $lastRun", style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, size: 20)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _runWorkflow(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purplePrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Run Now"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Edit"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
