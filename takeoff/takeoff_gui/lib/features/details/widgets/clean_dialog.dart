import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';

class CleanDialog extends StatelessWidget {
  final ProjectsController controller = GetIt.I.get<ProjectsController>();
  CleanDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.red.shade200,
      title: const Text(
        "Remove project",
        style: TextStyle(fontSize: 30),
      ),
      content: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "The project will be deleted from local cache, but not remove from cloud.",
            ),
            Text(
              "Once removed, you won't be able to add it again.",
            ),
            Text(
              "Do you want to continue removing it?",
            ),
          ],
        ),
      )),
      actions: [
        CustomButton(
          text: "Remove",
          icon: Icons.remove,
          color: Colors.red.shade600,
          onPressed: () {
            context.go("/");
            controller.clean();
          },
        ),
        CustomButton(
          text: "Close",
          icon: Icons.close,
          color: Colors.grey,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
