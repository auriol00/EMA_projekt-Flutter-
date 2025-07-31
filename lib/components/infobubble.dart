import 'package:flutter/material.dart';

class Infobubble extends StatelessWidget {
  final String message;
  final String? emoji;
  final IconData? icon;
  final bool selected;

  const Infobubble({
    super.key,
    required this.message,
    this.emoji,
    this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final backgroundColor = selected
        ? colorScheme.secondaryContainer
        : isDark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFFDF2F4); // ou colorScheme.surfaceVariant

    final borderColor = selected
        ? colorScheme.primary
        : Colors.transparent;

    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emoji != null)
            Text(
              emoji!,
              style: const TextStyle(fontSize: 20),
            )
          else
            Icon(
              icon ?? Icons.info_outline,
              color: iconColor,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
