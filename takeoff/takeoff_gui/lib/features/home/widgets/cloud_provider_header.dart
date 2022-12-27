// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:takeoff_gui/common/tooltip.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                ? TooltipMessage(
                    message: AppLocalizations.of(context)!
                        .logOutCloudProviderTooltip
                        .replaceAll("PROVIDER", name),
                    child: IconButton(
                      icon: const Icon(Icons.logout_outlined),
                      splashRadius: 16,
                      onPressed: () => logOutCallback(),
                    ),
                  )
                : TooltipMessage(
                    message: AppLocalizations.of(context)!
                        .logInCloudProviderTooltip
                        .replaceAll("PROVIDER", name),
                    child: IconButton(
                      icon: const Icon(Icons.login_outlined),
                      splashRadius: 16,
                      onPressed: () => authenticateCallback(),
                    ),
                  )
          ],
        ),
        Row(
          children: [
            Text(authAccount.isNotEmpty
                ? authAccount
                : AppLocalizations.of(context)!.notAuthentificatied),
          ],
        ),
      ],
    );
  }
}
