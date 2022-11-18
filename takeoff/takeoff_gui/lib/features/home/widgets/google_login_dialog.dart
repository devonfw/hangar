import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/utils/type_dialog.dart';
import 'package:takeoff_gui/features/home/widgets/auto_closing_dialog.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class GoogleLoginDialog extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final ProjectsController projectsController =
      GetIt.I.get<ProjectsController>();
  GoogleLoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => AlertDialog(
        title: const Text('Login on Google'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: !projectsController.waitForToken
              ? <Widget>[
                  const Text("Enter your google account:"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'i.e. example@gmail.com',
                    ),
                  ),
                ]
              : <Widget>[
                  const Text(
                      "A tab will open in your browser. Please follow the steps."),
                  const Text("Enter your token:"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'ahjkfdsyui32hcdh4uD',
                    ),
                  ),
                ],
        ),
        actions: <Widget>[
          !projectsController.waitForToken
              ? ElevatedButton(
                  onPressed: () {
                    _doLogin(context);
                  },
                  child: const Text('Login'),
                )
              : ElevatedButton(
                  onPressed: () {
                    projectsController.channel.add(controller.text.codeUnits);
                  },
                  child: const Text('Confirm token'),
                ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              projectsController.resetChannel();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _doLogin(context) {
    projectsController
        .initAccount(controller.text, CloudProviderId.gcloud)
        .then(
      (value) {
        projectsController.updateInitAccounts(CloudProviderId.gcloud);
        projectsController.waitForToken = false;
        Navigator.of(context).pop();
        projectsController.resetChannel();
        showDialog(
          context: context,
          builder: (BuildContext context) => AutoClosingDialog(
            typeDialog: value ? TypeDialog.success : TypeDialog.error,
            title: "Login",
            message: value
                ? "You're logged in Google"
                : "Something happened! Check your credentialss",
          ),
        );
      },
    );
    controller.clear();
  }
}
