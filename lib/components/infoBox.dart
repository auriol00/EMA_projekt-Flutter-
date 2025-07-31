import 'package:flutter/material.dart';

Widget infoBox({
  required String title,
  required String value,
  IconData? icon,
  EdgeInsetsGeometry? margin,
  EdgeInsetsGeometry? padding,
  bool isClickable = false,
  bool iconOnTop = false, //nouveau paramètre
}) {
  final effectiveMargin = margin ?? const EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 20,
  );
  final effectivePadding = padding ?? const EdgeInsets.symmetric(
    vertical: 16,
    horizontal: 16,
  );

  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final colorScheme = theme.colorScheme;

      final backgroundColor = isDark
          ? theme.cardColor
          : Colors.purple.shade50;

      final borderColor = isDark ? theme.dividerColor : null;

      final iconColor = isDark
          ? colorScheme.primary
          : Colors.purple.shade400;

      final textColor = isDark
          ? colorScheme.onSurface
          : Colors.black87;

      return Container(
        margin: effectiveMargin,
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
        ),
        child: iconOnTop
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Icon(icon, size: 30, color: iconColor),
                    ),
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(icon, size: 24, color: iconColor),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      );
    },
  );
}
