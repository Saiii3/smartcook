import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String tooltip;
  final IconData icon;

  const CustomFloatingActionButton({super.key, required this.onPressed, required this.tooltip, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 56.0,
          height: 56.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFdc754e),
          ),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}