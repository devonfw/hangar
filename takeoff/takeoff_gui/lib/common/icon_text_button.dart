import 'package:flutter/material.dart';

class IconTextButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final double? size;
  final Color? color;
  final void Function()? onPressed;
  const IconTextButton({
    Key? key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: size ?? 70,
          height: size ?? 70,
          child: Column(
            children: [
              Icon(
                icon,
                color: color ?? Colors.black,
                size: size != null ? (size! - 20) : 50,
              ),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
