import 'package:flutter/material.dart';
import 'package:moonflow/utilities/app_localizations.dart';

class SmartSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? hintText;

  const SmartSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText, // maintenant nullable
  });

  @override
  State<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends State<SmartSearchBar> {
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showBackArrow = _hasFocus || widget.controller.text.isNotEmpty;

    final effectiveHint = widget.hintText ??
        AppLocalizations.translate(context, 'search_posts');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Focus(
        onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: effectiveHint,
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                left: showBackArrow ? 0 : 12.0,
                right: 8.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBackArrow)
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: theme.iconTheme.color,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        widget.controller.clear();
                        widget.onChanged('');
                      },
                    ),
                  Icon(Icons.search, color: theme.iconTheme.color),
                ],
              ),
            ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close),
                    color: theme.iconTheme.color,
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                  )
                : null,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
