import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: onPressed == null ? 1.0 : 1.0, // Scale logic moved to stateful wrapper if needed
      duration: const Duration(milliseconds: 100),
      child: SizedBox(
        width: double.infinity,
        height: 80,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed != null ? Colors.greenAccent.shade700 : Colors.grey.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            elevation: onPressed != null ? 8 : 0,
            shadowColor: Colors.greenAccent.shade700.withOpacity(0.4),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 32),
                const SizedBox(width: 12),
              ],
              Text(
                text.toUpperCase(),
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
