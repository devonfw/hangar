import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_projects_list.dart';
import 'package:takeoff_gui/features/home/widgets/floating_action_menu.dart';
import 'package:takeoff_gui/features/home/widgets/google_login_dialog.dart';
import 'package:takeoff_gui/mocks/mock_projects.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ProjectsController projectsController = GetIt.I.get<ProjectsController>();
    ScrollController scrollController = ScrollController();

    return Scaffold(
      floatingActionButton: const FloatingActionMenu(),
      appBar: AppBar(
        title: const Text("Take Off"),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Observer(builder: (context) {
              return CloudProjectsList(
                name: "Google Cloud",
                projects: MockProjects.projectsGCloud,
                authenticateCallback: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => GoogleLoginDialog(),
                  );
                },
                authAccount:
                    projectsController.accounts[CloudProviderId.gcloud]!,
              );
            }),
            CloudProjectsList(
              name: "Azure",
              projects: MockProjects.projectsAzure,
              // TODO Add loggin method
              authenticateCallback: () => print("Authenticating on Azure"),
              authAccount: projectsController.accounts[CloudProviderId.azure]!,
            ),
            CloudProjectsList(
              name: 'AWS',
              projects: MockProjects.projectsAWS,
              // TODO Add loggin method
              authenticateCallback: () => print("Authenticating on AWS"),
              authAccount: projectsController.accounts[CloudProviderId.aws]!,
            ),
          ],
        ),
      ),
    );
  }
}
