import 'dart:async';

import 'package:flutter/material.dart';
import 'package:takeoff_gui/features/home/utils/type_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AutoClosingDialog extends StatefulWidget {
  final TypeDialog typeDialog;
  final String title;
  final String message;

  const AutoClosingDialog(
      {super.key,
      required this.typeDialog,
      required this.title,
      required this.message});

  @override
  State<AutoClosingDialog> createState() => _AutoClosingDialogState();
}

class _AutoClosingDialogState extends State<AutoClosingDialog> {
  late Timer timer;
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timer = Timer(
      const Duration(seconds: 3),
      (() => Navigator.of(context).pop()),
    );

    Color backgroundColor;
    Color buttonColor;
    switch (widget.typeDialog) {
      case TypeDialog.info:
        backgroundColor = Colors.blue.shade50;
        buttonColor = Colors.blue.shade400;
        break;
      case TypeDialog.success:
        backgroundColor = Colors.green.shade100;
        buttonColor = Colors.green.shade500;
        break;
      case TypeDialog.error:
        backgroundColor = Colors.red.shade200;
        buttonColor = Colors.red.shade600;
        break;
    }
    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text(widget.title),
      content: Text(widget.message),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
          ),
          onPressed: () {
            timer.cancel();
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.closeButton),
        ),
      ],
    );
  }
}
