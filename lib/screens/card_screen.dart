import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/card_item.dart';
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

  // Cache shuffled options so they don't reorder on every rebuild.
  List<String> _options = [];
  String? _lastCardId;

  void _cacheOptionsFor(CardItem card) {
    if (card.id != _lastCardId) {
      _options = List<String>.from(card.options);
      _lastCardId = card.id;
    }
  }

  void _handleAnswer(
    String chosen,
    SessionProvider session,
    ProgressProvider progress,
  ) {
    if (_showFeedback) return;

    final cardId = session.currentCard!.id;
    final result = session.submitAnswer(chosen);

    if (result == AnswerState.correct) {
      HapticFeedback.lightImpact();
      progress.recordCorrect(cardId);
      final cp = progress.progressFor(cardId);
      if (cp.mastered && cp.streak == 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌟  Card mastered!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      HapticFeedback.mediumImpact();
      progress.recordWrong(cardId);
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

  Future<bool> _confirmLeave(BuildContext context) async {
    final should = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave session?'),
        content: const Text('Your progress in this session will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    return should == true;
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

    _cacheOptionsFor(card);

    final rule = data.rule(card.ruleId);

    final parts = card.sentence.split('___');
    final beforeBlank = parts.isNotEmpty ? parts[0] : '';
    final afterBlank = parts.length > 1 ? parts[1] : '';

    AnswerState stateFor(String option) {
      if (!_showFeedback) return AnswerState.unanswered;
      if (option == card.correct) return AnswerState.correct;
      if (option == _chosenAnswer) return AnswerState.wrong;
      return AnswerState.unanswered;
    }

    final clusterId = session.session.clusterId;
    final title = clusterId == 'mix'
        ? 'Mix It Up'
        : clusterId == 'famous'
            ? 'Famous Lines'
            : data.cluster(clusterId)?.title ?? '';

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final should = await _confirmLeave(context);
        if (should && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontSize: 15)),
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
            Column(
              children: [
                LinearProgressIndicator(
                  value: session.progressFraction,
                  minHeight: 4,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Irregular / Famous badges
                        if (card.isIrregular || card.isFamous)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Wrap(
                              spacing: 8,
                              children: [
                                if (card.isIrregular)
                                  Chip(
                                    label: const Text('Fixed phrase'),
                                    backgroundColor:
                                        theme.colorScheme.tertiaryContainer,
                                    labelStyle: TextStyle(
                                      color: theme
                                          .colorScheme.onTertiaryContainer,
                                      fontSize: 12,
                                    ),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                if (card.isFamous)
                                  Chip(
                                    label: const Text('🎬 Famous'),
                                    backgroundColor:
                                        theme.colorScheme.secondaryContainer,
                                    labelStyle: TextStyle(
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                      fontSize: 12,
                                    ),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                          ),

                        // Sentence with animated blank
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
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 60,
                                  height: 3,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
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

                        // Answer buttons (stable order)
                        ..._options.map((option) => AnswerButton(
                              label: option,
                              state: stateFor(option),
                              onTap: () =>
                                  _handleAnswer(option, session, progress),
                            )),

                        // Space for feedback overlay
                        const SizedBox(height: 160),
                      ],
                    ),
                  ),
                ),
              ],
            ),

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
      ),
    );
  }
}
