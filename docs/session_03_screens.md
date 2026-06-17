# Session 03 — Screens and Widgets

## Goal
Build all UI screens. After this session: the app is fully playable end-to-end.
A user can browse clusters, read an intro, practice a session of 15 cards,
see immediate feedback after each answer, review a summary, and check overall
progress.

---

## Screen Map

```
HomeScreen
  ├── [tap cluster] → ClusterIntroScreen → CardScreen → SessionSummaryScreen
  ├── [Mix it up]  → CardScreen (mix pool) → SessionSummaryScreen
  ├── [Famous Lines] → CardScreen (famous pool) → SessionSummaryScreen
  └── [Progress]   → ProgressScreen
```

Navigation uses plain `Navigator.push` — no routing library needed.

---

## Widget: lib/widgets/answer_button.dart

The core interactive element. Renders in three states: default, correct, wrong.

```dart
import 'package:flutter/material.dart';
import '../services/session_service.dart';

class AnswerButton extends StatelessWidget {
  final String label;
  final AnswerState state;
  final VoidCallback? onTap;

  const AnswerButton({
    super.key,
    required this.label,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor;
    Color borderColor;
    IconData? icon;

    switch (state) {
      case AnswerState.correct:
        bgColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF155724);
        borderColor = const Color(0xFF28A745);
        icon = Icons.check_circle_outline;
      case AnswerState.wrong:
        bgColor = const Color(0xFFF8D7DA);
        textColor = const Color(0xFF721C24);
        borderColor = const Color(0xFFDC3545);
        icon = Icons.cancel_outlined;
      case AnswerState.unanswered:
        bgColor = theme.colorScheme.surface;
        textColor = theme.colorScheme.onSurface;
        borderColor = theme.colorScheme.outline;
        icon = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: state == AnswerState.unanswered ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: textColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Widget: lib/widgets/feedback_overlay.dart

Slides up from the bottom after an answer is submitted. Shows correct/wrong
status, the rule explanation, and a Next button.

```dart
import 'package:flutter/material.dart';
import '../models/rule.dart';
import '../services/session_service.dart';

class FeedbackOverlay extends StatelessWidget {
  final AnswerState state;
  final String chosenAnswer;
  final String correctAnswer;
  final Rule? rule;
  final String? famousSource;
  final VoidCallback onNext;

  const FeedbackOverlay({
    super.key,
    required this.state,
    required this.chosenAnswer,
    required this.correctAnswer,
    required this.rule,
    required this.famousSource,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = state == AnswerState.correct;

    final headerColor = isCorrect
        ? const Color(0xFF28A745)
        : const Color(0xFFDC3545);
    final headerText = isCorrect ? '✓  Correct!' : '✗  The answer is ${correctAnswer.toUpperCase()}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Text(
            headerText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: headerColor,
            ),
          ),
          const SizedBox(height: 12),

          // Rule explanation
          if (rule != null) ...[
            Text(
              rule!.short,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'e.g. ${rule!.example}',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Famous source attribution
          if (famousSource != null) ...[
            const SizedBox(height: 8),
            Text(
              '🎬  $famousSource',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Next button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: const Text('Next  →', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Widget: lib/widgets/cluster_tile.dart

Used on HomeScreen to display each cluster with its title, progress bar,
and mastery count.

```dart
import 'package:flutter/material.dart';
import '../models/cluster.dart';

class ClusterTile extends StatelessWidget {
  final Cluster cluster;
  final double mastery;       // 0.0 – 1.0
  final int masteredCount;
  final VoidCallback onTap;

  const ClusterTile({
    super.key,
    required this.cluster,
    required this.mastery,
    required this.masteredCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (mastery * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cluster.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cluster.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: mastery,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          mastery >= 1.0
                              ? const Color(0xFF28A745)
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$masteredCount / ${cluster.cards.length}  ($pct%)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Screen: lib/screens/home_screen.dart

The main hub. Shows cluster list, Mix it Up, Famous Lines, and Progress.

```dart
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
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
          // ── Quick-start buttons ──────────────────────────────────────────
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
                          const SnackBar(content: Text('You've mastered everything! Impressive.')),
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

          // ── Section header ───────────────────────────────────────────────
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

          // ── Cluster list ─────────────────────────────────────────────────
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
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(sublabel, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Screen: lib/screens/cluster_intro_screen.dart

Shows the rules for a cluster before the session starts. Each rule is shown
as its own card. A "Start Practising" button at the bottom launches the session.

```dart
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
          // Subtitle
          Text(
            cluster.subtitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Contrast note (if any)
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

          // Rule cards
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

          // Start button
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Practising', style: TextStyle(fontSize: 16)),
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

          // Card count info
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
```

---

## Screen: lib/screens/card_screen.dart

The main practice screen. Shows the sentence with a blank, answer buttons,
and the feedback overlay after each tap. Navigates to SessionSummaryScreen
when the session is complete.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/session_provider.dart';
import '../services/session_service.dart';
import '../widgets/answer_button.dart';
import '../widgets/feedback_overlay.dart';
import 'session_summary_screen.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  AnswerState _currentState = AnswerState.unanswered;
  String _chosenAnswer = '';
  bool _showFeedback = false;

  void _handleAnswer(String chosen, SessionProvider session, ProgressProvider progress) {
    if (_showFeedback) return; // already answered

    final result = session.submitAnswer(chosen);
    if (result == AnswerState.correct) {
      progress.recordCorrect(session.currentCard!.id);
    } else {
      progress.recordWrong(session.currentCard!.id);
    }

    setState(() {
      _chosenAnswer = chosen;
      _currentState = result;
      _showFeedback = true;
    });
  }

  void _handleNext(BuildContext context, SessionProvider session) {
    session.advance();

    if (session.isComplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SessionSummaryScreen()),
      );
      return;
    }

    setState(() {
      _currentState = AnswerState.unanswered;
      _chosenAnswer = '';
      _showFeedback = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final data = context.read<DataProvider>();
    final progress = context.read<ProgressProvider>();
    final theme = Theme.of(context);

    final card = session.currentCard;
    if (card == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final rule = data.rule(card.ruleId);

    // Split sentence into parts around the blank
    final parts = card.sentence.split('___');
    final beforeBlank = parts.isNotEmpty ? parts[0] : '';
    final afterBlank = parts.length > 1 ? parts[1] : '';

    // Determine state of each answer button
    AnswerState stateFor(String option) {
      if (!_showFeedback) return AnswerState.unanswered;
      if (option == card.correct) return AnswerState.correct;
      if (option == _chosenAnswer) return AnswerState.wrong;
      return AnswerState.unanswered;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          session.session.clusterId == 'mix'
              ? 'Mix It Up'
              : session.session.clusterId == 'famous'
                  ? 'Famous Lines'
                  : data.cluster(session.session.clusterId)?.title ?? '',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${session.currentIndex + 1} / ${session.totalCards}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Main content ─────────────────────────────────────────────────
          Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: session.progressFraction,
                minHeight: 4,
                backgroundColor: theme.colorScheme.surfaceVariant,
              ),

              // Sentence card
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // The sentence with the blank highlighted
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: beforeBlank),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Container(
                                width: 60,
                                height: 3,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: _showFeedback
                                      ? (_currentState == AnswerState.correct
                                          ? const Color(0xFF28A745)
                                          : const Color(0xFFDC3545))
                                      : theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            TextSpan(text: afterBlank),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Answer buttons
                      ...card.options.map((option) => AnswerButton(
                            label: option,
                            state: stateFor(option),
                            onTap: () => _handleAnswer(option, session, progress),
                          )),

                      // Spacing for feedback overlay
                      const SizedBox(height: 160),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Feedback overlay ────────────────────────────────────────────
          if (_showFeedback)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FeedbackOverlay(
                state: _currentState,
                chosenAnswer: _chosenAnswer,
                correctAnswer: card.correct,
                rule: rule,
                famousSource: card.isFamous ? card.source : null,
                onNext: () => _handleNext(context, session),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## Screen: lib/screens/session_summary_screen.dart

Shown after completing 15 cards. Displays score, lists wrong answers
with the correct preposition, and offers to continue or go home.

```dart
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
    if (pct >= 90) { emoji = '🏆'; message = 'Outstanding!'; }
    else if (pct >= 70) { emoji = '🎯'; message = 'Great work!'; }
    else if (pct >= 50) { emoji = '💪'; message = 'Keep going!'; }
    else { emoji = '📚'; message = 'Practice makes perfect.'; }

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
                Text(
                  message,
                  style: theme.textTheme.titleMedium,
                ),
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

          // Overall progress chip
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
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                          card.sentence.replaceAll('___', '___'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.close, color: Color(0xFFDC3545), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            answer.chosen.toUpperCase(),
                            style: const TextStyle(color: Color(0xFFDC3545), fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.check, color: Color(0xFF28A745), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            answer.correct.toUpperCase(),
                            style: const TextStyle(color: Color(0xFF28A745), fontWeight: FontWeight.bold),
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

          // Action buttons
          FilledButton(
            onPressed: () {
              // Play another session with the same pool
              // Re-draw using the same cluster
              Navigator.pop(context); // back to ClusterIntroScreen or Home
            },
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
```

---

## Screen: lib/screens/progress_screen.dart

Shows overall progress and per-cluster breakdown. Accessible from the Home
AppBar icon.

```dart
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
      appBar: AppBar(
        title: const Text('My Progress'),
      ),
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
                      backgroundColor: theme.colorScheme.surfaceVariant,
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
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                        backgroundColor: theme.colorScheme.surfaceVariant,
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

          // Reset option — wrapped in confirmation dialog
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, color: Colors.red),
            label: const Text('Reset All Progress', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
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
        content: const Text('This will clear all mastery data. You will start fresh. This cannot be undone.'),
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
```

---

## Verification

Run `flutter run` on device. Verify end-to-end:

1. Home screen shows 7 cluster tiles with 0% progress bars.
2. Tapping a cluster opens ClusterIntroScreen with readable rules.
3. Tapping "Start Practising" opens CardScreen with a sentence and 4 buttons.
4. Tapping an answer shows the feedback overlay with the rule explanation.
5. Tapping "Next" advances the card. Progress bar moves.
6. After card 15, SessionSummaryScreen appears with score.
7. "Back to Home" returns to HomeScreen.
8. "Mix It Up" and "Famous Lines" launch sessions correctly.
9. Progress screen shows stats and per-cluster bars.
10. Reset dialog works.

Run `flutter analyze` — zero errors or warnings.
Commit on branch `feature/screens`.
