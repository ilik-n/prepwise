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
