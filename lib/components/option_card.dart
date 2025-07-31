import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFEDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color.fromARGB(255, 229, 134, 191) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
