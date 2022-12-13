import 'package:flutter/material.dart';

class ErrorLoadingPage extends StatelessWidget {
  final String message;
  const ErrorLoadingPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Error",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Some error happened"),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
