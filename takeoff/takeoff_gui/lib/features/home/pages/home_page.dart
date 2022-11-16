import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_projects_list.dart';
import 'package:takeoff_gui/features/home/widgets/floating_action_menu.dart';
import 'package:takeoff_gui/mocks/mock_projects.dart';

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
                      builder: (BuildContext context) => GoogleLoginDialog());
                },
                authAccount: projectsController.accounts["gc"],
              );
            }),
            CloudProjectsList(
              name: "Azure",
              projects: MockProjects.projectsAzure,
              authenticateCallback: () => print("Authenticating on Azure"),
              authAccount: "fakeazureaccount@capgemini.com",
            ),
            CloudProjectsList(
              name: 'AWS',
              projects: MockProjects.projectsAWS,
              authenticateCallback: () => print("Authenticating on AWS"),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleLoginDialog extends StatelessWidget {
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'i.e. example@gmail.com',
                    ),
                    onChanged: ((value) => projectsController.emailgc = value),
                  ),
                ]
              : <Widget>[
                  const Text("Enter your token:"),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'ahjkfdsyui32hcdh4uD',
                    ),
                    onChanged: ((value) =>
                        projectsController.channel.add(value)),
                  ),
                ],
        ),
        actions: <Widget>[
          !projectsController.waitForToken
              ? ElevatedButton(
                  onPressed: () {
                    projectsController.initAccount("gc");
                  },
                  child: const Text('Login'),
                )
              : ElevatedButton(
                  onPressed: () {},
                  child: const Text('Confirm token'),
                ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
