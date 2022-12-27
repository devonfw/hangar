import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/monitor/pages/monitor_dialog.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/common/tooltip.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class WayatForm extends StatelessWidget {
  final QuickstartController controller = GetIt.I.get<QuickstartController>();

  WayatForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
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
            const SizedBox(width: 20),
            Expanded(
              child: Observer(builder: (_) {
                if (controller.region.isEmpty) {
                  controller.region = firebaseRegions.first;
                }

                return DropdownButtonFormField(
                    decoration: InputDecoration(
                      label: Text(AppLocalizations.of(context)!.region),
                      border: const OutlineInputBorder(),
                    ),
                    hint: Text(AppLocalizations.of(context)!.region),
                    items: firebaseRegions
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    value: controller.region,
                    onChanged: (value) => controller.region = value!);
              }),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Observer(
              builder: (_) => TooltipMessage(
                message: AppLocalizations.of(context)!.quickStartButtonTooltip,
                child: CustomButton(
                    onPressed: controller.isValidForm
                        ? () {
                            Navigator.of(context).pop();
                            controller.createWayat();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) =>
                                  MonitorDialog(),
                            );
                          }
                        : null,
                    icon: Icons.add_box_outlined,
                    text: "Quickstart"),
              ),
            )
          ],
        )
      ],
    );
  }
}
