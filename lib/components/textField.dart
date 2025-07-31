import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FocusNode? focusNode;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool showBorder;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.focusNode,
    this.minLines = 1,
    this.maxLines = 5,
    this.keyboardType,
    this.onChanged,
    this.showBorder = true,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscure;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    widget.focusNode?.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _hasFocus = widget.focusNode?.hasFocus ?? false);
  }

  void _toggleVisibility() {
    setState(() => _obscure = !_obscure);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Focus(
        onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: widget.showBorder
                ? Border.all(
                    color: _hasFocus
                        ? colorScheme.primary
                        : theme.dividerColor,
                    width: 1.0,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextField(
              focusNode: widget.focusNode,
              controller: widget.controller,
              obscureText: _obscure,
              keyboardType: widget.keyboardType ?? TextInputType.multiline,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              onChanged: widget.onChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
              borderSide: BorderSide.none,
            ),
                hintText: widget.hintText,
                hintStyle: theme.inputDecorationTheme.hintStyle,
                suffixIcon: widget.obscureText
                    ? IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: theme.iconTheme.color,
                        ),
                        onPressed: _toggleVisibility,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}