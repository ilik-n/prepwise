import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/session_provider.dart';
import '../providers/progress_provider.dart';
import 'home_screen.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionProvider>();
    final data = context.read<DataProvider>();
    final progress = context.read<ProgressProvider>();
    final theme = Theme.of(context);

    final correct = session.correctCount;
    final total = session.totalCards;
    final pct = (session.scorePercent * 100).round();
    final wrongAnswers = session.session.wrongAnswers;

    String emoji;
    String message;
    if (pct >= 90) {
      emoji = '🏆';
      message = 'Outstanding!';
    } else if (pct >= 70) {
      emoji = '🎯';
      message = 'Great work!';
    } else if (pct >= 50) {
      emoji = '💪';
      message = 'Keep going!';
    } else {
      emoji = '📚';
      message = 'Practice makes perfect.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Complete'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Score hero
          Center(
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                Text(
                  '$correct / $total',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(message, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '$pct% correct',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Center(
            child: Chip(
              avatar: const Icon(Icons.auto_awesome, size: 16),
              label: Text(
                '${progress.totalMastered} / ${progress.totalCards} cards mastered overall',
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Wrong answers review
          if (wrongAnswers.isNotEmpty) ...[
            Text(
              'Review',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...wrongAnswers.map((answer) {
              final card = data.card(answer.cardId);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (card != null)
                        Text(
                          card.sentence,
                          style: theme.textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.close,
                            color: Color(0xFFDC3545),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            answer.chosen.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFDC3545),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.check,
                            color: Color(0xFF28A745),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            answer.correct.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF28A745),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 24),

          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Play Again'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}
