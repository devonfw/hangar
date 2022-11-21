import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';

class ProjectDataForm extends StatelessWidget {
  final CreateController controller = GetIt.I.get<CreateController>();
  ProjectDataForm({
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
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Project name"),
                onChanged: (value) => controller.projectName = value,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Billing Account"),
                onChanged: (value) => controller.billingAccount = value,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
