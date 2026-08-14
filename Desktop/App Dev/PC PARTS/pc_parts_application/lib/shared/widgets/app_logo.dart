import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF081226),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.computer_outlined,
        color: Colors.white,
      ),
    );
  }
}