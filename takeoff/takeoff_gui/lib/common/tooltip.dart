// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class TooltipMessage extends StatelessWidget {
  final String message;
  final Widget child;
  const TooltipMessage({
    Key? key,
    required this.message,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
            colors: <Color>[Colors.black87, Colors.black87]),
      ),
      height: 30,
      padding: const EdgeInsets.all(8.0),
      preferBelow: false,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      showDuration: const Duration(seconds: 1),
      waitDuration: const Duration(seconds: 1),
      child: child,
    );
  }
}
