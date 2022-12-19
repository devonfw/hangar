import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function? onPressed;
  final Color? color;
  const CustomButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed == null ? null : () => onPressed!(),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(150, 50),
        maximumSize: const Size(170, 50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}