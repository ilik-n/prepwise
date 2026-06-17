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

    final headerColor =
        isCorrect ? const Color(0xFF28A745) : const Color(0xFFDC3545);
    final headerText = isCorrect
        ? '✓  Correct!'
        : '✗  The answer is ${correctAnswer.toUpperCase()}';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
          Text(
            headerText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: headerColor,
            ),
          ),
          const SizedBox(height: 12),

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
