import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/scan_provider.dart';
import '../../models/scan_result.dart';
import '../../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
      ),
      body: Consumer<ScanProvider>(
        builder: (context, scanProv, child) {
          if (scanProv.isLoading && scanProv.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (scanProv.history.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => scanProv.loadHistory(),
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: scanProv.history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final scan = scanProv.history[index];
                return _buildHistoryCard(context, scan);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppTheme.divider),
          const SizedBox(height: 24),
          Text(
            'No Analysis Yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your skin tone results will appear here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedText,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ScanResult scan) {
    return InkWell(
      onTap: () {
        // Navigate to result detail if needed
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider, width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Color(int.parse(scan.hex.replaceFirst('#', '0xFF'))),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.divider),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${scan.depth} ${scan.undertone}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(scan.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.mutedText),
          ],
        ),
      ),
    );
  }
}
