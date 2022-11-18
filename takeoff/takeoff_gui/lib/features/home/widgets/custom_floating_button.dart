import 'package:flutter/material.dart';

class CustomFloatingButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onPressed;
  const CustomFloatingButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(150, 50),
        maximumSize: const Size(150, 50),
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
