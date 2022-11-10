import 'package:flutter/material.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_projects_list.dart';
import 'package:takeoff_gui/mocks/mock_projects.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Off"),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CloudProjectsList(
              name: "Google Cloud",
              projects: MockProjects.projectsGCloud,
              authenticateCallback: () => print("Authenticating on gcloud"),
            ),
            CloudProjectsList(
                name: "Azure",
                projects: MockProjects.projectsAzure,
                authenticateCallback: () => print("Authenticating on Azure")),
            CloudProjectsList(
                name: 'AWS',
                projects: MockProjects.projectsAWS,
                authenticateCallback: () => print("Authenticating on AWS")),
          ],
        ),
      ),
    );
  }
}
