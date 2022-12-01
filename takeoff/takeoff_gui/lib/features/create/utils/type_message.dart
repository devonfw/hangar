import 'package:flutter/material.dart';

enum TypeMessage {
  info(color: Colors.blue),
  action(color: Colors.grey),
  success(color: Colors.green),
  error(color: Colors.red);

  const TypeMessage({required this.color});

  final Color color;
}
