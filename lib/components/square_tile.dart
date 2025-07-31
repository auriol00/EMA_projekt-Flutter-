import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget{
  final String imagePath;
  final Function()?onTap;
  final int height;
  final int width;
  final String text;


  const SquareTile({
    super.key,
    required this.imagePath,
    required this.onTap,
    required this.height,
    required this.width,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height.toDouble(),
        width: width.toDouble(),
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 24,
              width: 24,
            ),
          const SizedBox(width: 12),
          Text(text,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          )
        ],
        
        )
      
      ),
    );
  }
}