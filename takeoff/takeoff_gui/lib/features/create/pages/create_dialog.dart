import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/home/widgets/custom_floating_button.dart';

class CreateDialog extends StatelessWidget {
  final CreateController controller = GetIt.I.get<CreateController>();
  CreateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create a project",
              style: TextStyle(fontSize: 30),
            ),
            ProviderSelector(),
            RepoProvider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Project name"),
                    onChanged: (value) => controller.projectName = value,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Billing Account"),
                    onChanged: (value) => controller.billingAccount = value,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Observer(
                      builder: (context) => DropdownField(
                            callback: (String? s) =>
                                controller.frontendLanguage = s ?? "",
                            dropdownValue: controller.frontendLanguage,
                            values: const ["Flutter", "Angular", "React"],
                          )),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Observer(
                      builder: (context) => DropdownField(
                            callback: (String? s) =>
                                controller.frontendVersion = s ?? "",
                            dropdownValue: controller.frontendVersion,
                            values: const ["v10", "v11", "v12"],
                          )),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Observer(
                      builder: (context) => DropdownField(
                            callback: (String? s) =>
                                controller.backendLanguage = s ?? "",
                            dropdownValue: controller.backendLanguage,
                            values: const ["Python", "Java", ".NET"],
                          )),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Observer(
                      builder: (context) => DropdownField(
                            callback: (String? s) =>
                                controller.backendVersion = s ?? "",
                            dropdownValue: controller.backendVersion,
                            values: const ["v10", "v11", "v12"],
                          )),
                ),
              ],
            ),
          ],
        ),
      )),
      actions: [
        CustomFloatingButton(
          text: "Create",
          icon: Icons.add,
          onPressed: () => print("creating"),
        ),
        CustomFloatingButton(
          text: "Close",
          icon: Icons.close,
          color: Colors.red,
          onPressed: () {
            Navigator.of(context).pop();
            controller.resetForm();
          },
        )
      ],
    );
  }
}

class DropdownField extends StatelessWidget {
  final String? dropdownValue;
  final Function(String?) callback;
  final List<String> values;
  const DropdownField({
    Key? key,
    required this.dropdownValue,
    required this.values,
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      onChanged: (String? value) {
        callback(value);
      },
      items: values.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class ProviderSelector extends StatelessWidget {
  final BoxBorder border = Border.all(color: Colors.grey, width: 3);
  final BoxBorder selectedBorder =
      Border.all(color: Colors.indigoAccent, width: 5);
  final double squareSize = 130;
  final CreateController controller = GetIt.I.get<CreateController>();
  ProviderSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select a cloud provider"),
        const SizedBox(height: 15),
        Row(
          children: [
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.cloudProvider == "Google"
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage("assets/images/google_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.cloudProvider = "Google",
            ),
            const SizedBox(width: 20),
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.cloudProvider == "AWS"
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage("assets/images/aws_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.cloudProvider = "AWS",
            ),
            const SizedBox(width: 20),
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.cloudProvider == "Azure"
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage("assets/images/azure_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.cloudProvider = "Azure",
            ),
          ],
        ),
      ],
    );
  }
}

class RepoProvider extends StatelessWidget {
  final BoxBorder border = Border.all(color: Colors.grey, width: 3);
  final BoxBorder selectedBorder =
      Border.all(color: Colors.indigoAccent, width: 5);
  final double squareSize = 130;
  final CreateController controller = GetIt.I.get<CreateController>();
  RepoProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select a cloud provider"),
        const SizedBox(height: 15),
        Row(
          children: [
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.repoProvider == "Google"
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage("assets/images/google_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.repoProvider = "Google",
            ),
            const SizedBox(width: 20),
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.repoProvider == "AzureDevOps"
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image:
                            AssetImage("assets/images/azure_devops_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.repoProvider = "AzureDevOps",
            ),
            const SizedBox(width: 20),
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.repoProvider == "Github"
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage("assets/images/github_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.repoProvider = "Github",
            ),
          ],
        ),
      ],
    );
  }
}
