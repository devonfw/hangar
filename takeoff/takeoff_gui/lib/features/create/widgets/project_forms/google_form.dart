import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
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
        const Text("Project data"),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Observer(
                builder: (_) => TextField(
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Project name",
                      errorText: controller.projectName.isEmpty
                          ? "This field is required"
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
                      labelText: "Billing Account",
                      errorText: controller.billingAccount.isEmpty
                          ? "This field is required"
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
                      labelText: "Region",
                      errorText: controller.region.isEmpty
                          ? "This field is required"
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
