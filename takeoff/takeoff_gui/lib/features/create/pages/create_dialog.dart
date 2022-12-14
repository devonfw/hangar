import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/common/monitor/pages/monitor_dialog.dart';
import 'package:takeoff_gui/features/create/widgets/widgets.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/l10n/app_localizations.dart';

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
            Text(
              AppLocalizations.of(context).createProject,
              style: const TextStyle(fontSize: 30),
            ),
            CloudSelector(),
            const SizedBox(height: 10),
            RepoSelector(),
            const SizedBox(height: 10),
            ProjectForm(),
            const SizedBox(height: 10),
            FrontendForm(),
            const SizedBox(height: 10),
            BackendForm(),
          ],
        ),
      )),
      actions: [
        Observer(
          builder: (_) => CustomButton(
            text: AppLocalizations.of(context).createButton,
            icon: Icons.add,
            onPressed: !controller.isValid
                ? null
                : () {
                    Navigator.of(context).pop();
                    controller.createProject();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) => MonitorDialog(),
                    );
                  },
          ),
        ),
        CustomButton(
          text: AppLocalizations.of(context).closeButton,
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
