import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_projects_list.dart';
import 'package:takeoff_gui/features/home/widgets/floating_action_menu.dart';
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
                    projectsController.accounts[CloudProviderId.gcloud],
              );
            }),
            CloudProjectsList(
              name: "Azure",
              projects: MockProjects.projectsAzure,
              // TODO Add loggin method
              authenticateCallback: () => print("Authenticating on Azure"),
              authAccount: projectsController.accounts[CloudProviderId.azure],
            ),
            CloudProjectsList(
              name: 'AWS',
              projects: MockProjects.projectsAWS,
              // TODO Add loggin method
              authenticateCallback: () => print("Authenticating on AWS"),
              authAccount: projectsController.accounts[CloudProviderId.aws],
            ),
          ],
        ),
      ),
    );
  }
}

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
                    projectsController
                        .initAccount(controller.text, CloudProviderId.gcloud)
                        .then(
                      (value) {
                        projectsController
                            .updateInitAccounts(CloudProviderId.gcloud);
                        projectsController.waitForToken = false;
                        Navigator.of(context).pop();
                        projectsController.resetChannel();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AutoClosingDialog(
                            typeDialog:
                                value ? TypeDialog.success : TypeDialog.error,
                            title: "Login",
                            message: value
                                ? "You're logged in Google"
                                : "Something happened! Check your credentialss",
                          ),
                        );
                      },
                    );
                    controller.clear();
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
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

enum TypeDialog {
  info,
  success,
  error,
}

class AutoClosingDialog extends StatelessWidget {
  final TypeDialog typeDialog;
  final String title;
  final String message;

  const AutoClosingDialog(
      {super.key,
      required this.typeDialog,
      required this.title,
      required this.message});

  @override
  Widget build(BuildContext context) {
    Timer timer = Timer(
      const Duration(seconds: 3),
      (() => Navigator.of(context).pop()),
    );

    Color backgroundColor;
    Color buttonColor;
    switch (typeDialog) {
      case TypeDialog.info:
        backgroundColor = Colors.blue.shade50;
        buttonColor = Colors.blue.shade400;
        break;
      case TypeDialog.success:
        backgroundColor = Colors.green.shade100;
        buttonColor = Colors.green.shade500;
        break;
      case TypeDialog.error:
        backgroundColor = Colors.red.shade200;
        buttonColor = Colors.red.shade600;
        break;
    }
    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
          ),
          onPressed: () {
            timer.cancel();
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
