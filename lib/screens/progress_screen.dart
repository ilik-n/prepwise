import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final progress = context.watch<ProgressProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${progress.totalMastered}',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'of ${progress.totalCards} cards mastered',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress.overallMastery,
                      minHeight: 10,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress.overallMastery * 100).round()}% overall',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'By Cluster',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ...data.clusters.map((cluster) {
            final mastery = progress.clusterMastery(cluster);
            final mastered = progress.clusterMasteredCount(cluster);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cluster.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '$mastered / ${cluster.cards.length}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: mastery,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          mastery >= 1.0
                              ? const Color(0xFF28A745)
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.red),
            label: const Text(
              'Reset All Progress',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: () => _showResetDialog(context, progress),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, ProgressProvider progress) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will clear all mastery data. You will start fresh. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await progress.resetAll();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
