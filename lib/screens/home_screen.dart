import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/cluster_tile.dart';
import 'cluster_intro_screen.dart';
import 'card_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final progress = context.watch<ProgressProvider>();
    final session = context.read<SessionProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      appBar: AppBar(
        title: const Text(
          'PrepWise',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Progress',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgressScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: [
          // ── Quick-start buttons ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _QuickButton(
                    label: '🎲  Mix It Up',
                    sublabel: 'All topics, random',
                    onTap: () {
                      final pool = progress.mixPool;
                      if (pool.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("You've mastered everything! Impressive."),
                          ),
                        );
                        return;
                      }
                      final cards = progress.drawSession(pool);
                      session.startSession(cards: cards, clusterId: 'mix');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CardScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickButton(
                    label: '🎬  Famous Lines',
                    sublabel: 'Songs & films',
                    onTap: () {
                      final pool = progress.famousPool;
                      final cards = progress.drawSession(pool);
                      session.startSession(cards: cards, clusterId: 'famous');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CardScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Section header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Text(
              'Confusion Clusters',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // ── Cluster list ───────────────────────────────────────────────────
          ...data.clusters.map((cluster) {
            return ClusterTile(
              cluster: cluster,
              mastery: progress.clusterMastery(cluster),
              masteredCount: progress.clusterMasteredCount(cluster),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClusterIntroScreen(cluster: cluster),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _QuickButton({
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
