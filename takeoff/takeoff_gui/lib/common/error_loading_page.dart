import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorLoadingPage extends StatelessWidget {
  final String message;
  const ErrorLoadingPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppLocalizations.of(context)!.errorTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.errorMessage),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.red,
                  size: 150,
                ),
                const SizedBox(height: 50),
                Text(
                  message,
                  style: const TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
