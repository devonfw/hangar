// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CloudProviderHeader extends StatelessWidget {
  const CloudProviderHeader({
    Key? key,
    required this.name,
    required this.authAccount,
    required this.authenticateCallback,
    required this.logOutCallback,
  }) : super(key: key);

  final String name;
  final String authAccount;
  final Function authenticateCallback;
  final Function logOutCallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(name),
            authAccount.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.logout_outlined),
                    splashRadius: 16,
                    onPressed: () => logOutCallback(),
                  )
                : IconButton(
                    icon: const Icon(Icons.login_outlined),
                    splashRadius: 16,
                    onPressed: () => authenticateCallback(),
                  )
          ],
        ),
        Row(
          children: [
            Text(authAccount.isNotEmpty ? authAccount : "Not authenticated"),
          ],
        ),
      ],
    );
  }
}
