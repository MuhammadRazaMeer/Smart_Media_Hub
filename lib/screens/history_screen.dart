import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_media_hub/services/storage_service.dart';
import 'package:smart_media_hub/theme/app_colors.dart';
import 'package:smart_media_hub/widgets/app_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("History", style: Theme.of(context).textTheme.displayLarge),
                  Text("Track your processed media files", style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                            decoration: InputDecoration(
                              icon: const Icon(Icons.search),
                              hintText: "Search history...",
                              hintStyle: Theme.of(context).textTheme.labelSmall,
                              border: InputBorder.none,
                              suffixIcon: _searchQuery.isNotEmpty 
                                ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = "")) 
                                : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _storageService.historyStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  var docs = snapshot.data!.docs;
                  if (_searchQuery.isNotEmpty) {
                    docs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['fileName'] ?? "").toString().toLowerCase();
                      return name.contains(_searchQuery.toLowerCase());
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return Center(child: Text("No results found for '$_searchQuery'"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildHistoryCard(doc.id, data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text("No files yet", style: Theme.of(context).textTheme.headlineMedium),
          Text("Start using tools to see history", style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(String id, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.purpleBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_outlined, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['fileName'] ?? 'Untitled', style: Theme.of(context).textTheme.titleMedium),
                  Text("${data['operation']} • ${data['fileType']}", style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded, color: AppColors.purplePrimary),
            ),
            IconButton(
              onPressed: () => _storageService.deleteHistoryItem(id),
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
            ),
          ],
        ),
      ),
    );
  }
}
