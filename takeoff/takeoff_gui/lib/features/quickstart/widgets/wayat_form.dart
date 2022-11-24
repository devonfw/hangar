import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class WayatForm extends StatelessWidget {
  final QuickstartController controller = GetIt.I.get<QuickstartController>();
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();
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
                      labelText: "Billing Account",
                      errorText: controller.billingAccount.isEmpty
                          ? "This field is required"
                          : null),
                  onChanged: (value) => controller.billingAccount = value,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Observer(
                builder: (_) => TextField(
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Region",
                      errorText: controller.region.isEmpty
                          ? "This field is required"
                          : null),
                  onChanged: (value) => controller.region = value,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Observer(
              builder: (_) => ElevatedButton(
                  onPressed:
                      controller.isValidForm ? () => print("Click") : null,
                  child: Text("Create")),
            )
          ],
        )
      ],
    );
  }
}
