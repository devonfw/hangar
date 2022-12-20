import 'package:flutter/material.dart';
import 'package:takeoff_gui/domain/project.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_provider_header.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_project_item.dart';

class CloudProjectsList extends StatelessWidget {
  final String name;
  final List<Project> projects;
  final String authAccount;
  final Function authenticateCallback;
  final Function logOutCallback;
  const CloudProjectsList({
    super.key,
    required this.name,
    required this.projects,
    required this.authenticateCallback,
    required this.authAccount,
    required this.logOutCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: CloudProviderHeader(
              name: name,
              authenticateCallback: authenticateCallback,
              authAccount: authAccount,
              logOutCallback: logOutCallback,
            ),
          ),
          const SizedBox(height: 10),
          // List of projects
          if (authAccount.isNotEmpty && projects.isNotEmpty)
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    return CloudProjectItem(
                      project: projects[index],
                    );
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
