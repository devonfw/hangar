import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/utils/type_dialog.dart';
import 'package:takeoff_gui/features/home/widgets/auto_closing_dialog.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GoogleLoginDialog extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final ProjectsController projectsController =
      GetIt.I.get<ProjectsController>();
  GoogleLoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.loginGoogleMessage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: !projectsController.waitForToken
              ? <Widget>[
                  Text(AppLocalizations.of(context)!.enterGoogleAccountMessage),
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
                  Text(AppLocalizations.of(context)!.openTabMessage),
                  Text(AppLocalizations.of(context)!.enterTokenMessage),
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
                  child: Text(AppLocalizations.of(context)!.loginButton),
                )
              : ElevatedButton(
                  onPressed: () {
                    projectsController.channel.add(controller.text.codeUnits);
                  },
                  child: Text(AppLocalizations.of(context)!.confirmTokenButton),
                ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              projectsController.resetChannel();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.closeButton),
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
        projectsController.updateInitAccounts();
        projectsController.waitForToken = false;
        Navigator.of(context).pop();
        projectsController.resetChannel();
        showDialog(
          context: context,
          builder: (BuildContext context) => AutoClosingDialog(
            typeDialog: value ? TypeDialog.success : TypeDialog.error,
            title: AppLocalizations.of(context)!.loginButton,
            message: value
                ? AppLocalizations.of(context)!.loggedInMessage
                : AppLocalizations.of(context)!.loginFailedMessage,
          ),
        );
      },
    );
    controller.clear();
  }
}
