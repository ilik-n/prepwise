import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cluster.dart';
import '../providers/data_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/session_provider.dart';
import 'card_screen.dart';

class ClusterIntroScreen extends StatelessWidget {
  final Cluster cluster;

  const ClusterIntroScreen({super.key, required this.cluster});

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();
    final progress = context.read<ProgressProvider>();
    final session = context.read<SessionProvider>();
    final theme = Theme.of(context);

    final rules = cluster.introRules
        .map((id) => data.rule(id))
        .where((r) => r != null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(cluster.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            cluster.subtitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          if (cluster.contrastNote.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                cluster.contrastNote,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          ...rules.map((rule) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule!.short,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rule.example,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 24),

          FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'Start Practising',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              final pool = progress.poolForCluster(cluster);
              final cards = progress.drawSession(pool);
              session.startSession(cards: cards, clusterId: cluster.id);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CardScreen()),
              );
            },
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              '${cluster.cards.length} cards in this cluster',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
