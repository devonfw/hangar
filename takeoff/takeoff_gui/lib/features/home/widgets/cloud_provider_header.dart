import 'package:flutter/material.dart';

class CloudProviderHeader extends StatelessWidget {
  const CloudProviderHeader({
    Key? key,
    required this.name,
    required this.authenticateCallback,
  }) : super(key: key);

  final String name;
  final Function authenticateCallback;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(name),
      IconButton(
        icon: const Icon(Icons.login_outlined),
        splashRadius: 16,
        onPressed: () => authenticateCallback(),
      )
    ]);
  }
}
