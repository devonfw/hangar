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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: SizedBox(
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color ?? Colors.white,
                  size: size != null ? (size! - 20) : 30,
                ),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: color ?? Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
