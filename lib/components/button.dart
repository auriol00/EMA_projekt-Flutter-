import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final bool isDisabled;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;




  const MyButton({
    super.key, 
    required this.onTap,
    required this.text,
    this.isDisabled = false,
    this.borderRadius = 12,
    this.backgroundColor = const Color(0xFFC64995),
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal:25),

    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
      )
    );
  }
}
