import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final void Function()? onTap;

  const DeleteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.delete,
        color: colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}
