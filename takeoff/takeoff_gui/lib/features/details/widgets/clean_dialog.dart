import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CleanDialog extends StatelessWidget {
  final ProjectsController controller = GetIt.I.get<ProjectsController>();
  CleanDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.red.shade200,
      title: Text(
        AppLocalizations.of(context)!.removeProject,
        style: TextStyle(fontSize: 30),
      ),
      content: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.projectWillBeDeleted,
            ),
            Text(
              AppLocalizations.of(context)!.onceRemovedProject,
            ),
            Text(
              AppLocalizations.of(context)!.confirmationDeleteProject,
            ),
          ],
        ),
      )),
      actions: [
        CustomButton(
          text: AppLocalizations.of(context)!.removeButton,
          icon: Icons.remove,
          color: Colors.red.shade600,
          onPressed: () {
            context.go("/");
            controller.clean();
          },
        ),
        CustomButton(
          text: AppLocalizations.of(context)!.closeButton,
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
