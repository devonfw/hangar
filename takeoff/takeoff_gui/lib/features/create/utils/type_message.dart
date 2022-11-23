import 'package:flutter/material.dart';

enum TypeMessage {
  info(color: Colors.blue),
  error(color: Colors.red),
  success(color: Colors.green);

  const TypeMessage({required this.color});

  final Color color;
}
