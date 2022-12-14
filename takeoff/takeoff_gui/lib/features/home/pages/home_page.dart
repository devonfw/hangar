import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_projects_list.dart';
import 'package:takeoff_gui/features/home/widgets/floating_action_menu.dart';
import 'package:takeoff_gui/features/home/widgets/google_login_dialog.dart';
import 'package:takeoff_gui/l10n/app_localizations.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final ProjectsController projectsController =
      GetIt.I.get<ProjectsController>();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    projectsController.updateInitAccounts();
    return Scaffold(
      floatingActionButton: FloatingActionMenu(),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Observer(builder: (context) {
              return CloudProjectsList(
                name: AppLocalizations.of(context).gc,
                projects:
                    projectsController.projects[CloudProviderId.gcloud] ?? [],
                authenticateCallback: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => GoogleLoginDialog(),
                  );
                },
                logOutCallback: () =>
                    projectsController.logOut(CloudProviderId.gcloud),
                authAccount:
                    projectsController.accounts[CloudProviderId.gcloud]!,
              );
            }),
            CloudProjectsList(
              name: AppLocalizations.of(context).az,
              projects:
                  projectsController.projects[CloudProviderId.azure] ?? [],
              // TODO Add loggin method
              authenticateCallback: () => print("Authenticating on Azure"),
              logOutCallback: () => print("LogOut on Azure"),
              authAccount: projectsController.accounts[CloudProviderId.azure]!,
            ),
            CloudProjectsList(
              name: AppLocalizations.of(context).aws,
              projects: projectsController.projects[CloudProviderId.aws] ?? [],
              // TODO Add loggin method
              authenticateCallback: () => print("Authenticating on AWS"),
              logOutCallback: () => print("LogOut on AWS"),
              authAccount: projectsController.accounts[CloudProviderId.aws]!,
            ),
          ],
        ),
      ),
    );
  }
}
