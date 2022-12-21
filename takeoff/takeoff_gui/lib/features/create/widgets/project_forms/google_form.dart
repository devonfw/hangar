import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/google_form_controller.dart';

class GoogleForm extends StatelessWidget {
  final GoogleFormController controller = GetIt.I.get<GoogleFormController>();
  GoogleForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.projectData),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Observer(
                builder: (_) => TextField(
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.projectName,
                      errorText: controller.projectName.isEmpty
                          ? AppLocalizations.of(context)!.fieldRequired
                          : null),
                  onChanged: (value) => controller.projectName = value,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Observer(
                builder: (_) => TextField(
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.billingAccount,
                      errorText: controller.billingAccount.isEmpty
                          ? AppLocalizations.of(context)!.fieldRequired
                          : null),
                  onChanged: (value) => controller.billingAccount = value,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Observer(
                builder: (_) => TextField(
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.region,
                      errorText: controller.region.isEmpty
                          ? AppLocalizations.of(context)!.fieldRequired
                          : null),
                  onChanged: (value) => controller.region = value,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }
}
