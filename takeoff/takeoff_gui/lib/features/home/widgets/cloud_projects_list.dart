import 'package:flutter/material.dart';
import 'package:takeoff_gui/domain/project.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_provider_header.dart';
import 'package:takeoff_gui/features/home/widgets/cloud_provider_item.dart';

class CloudProjectsList extends StatelessWidget {
  final String name;
  final List<Project> projects;
  final Function authenticateCallback;
  const CloudProjectsList(
      {super.key,
      required this.name,
      required this.projects,
      required this.authenticateCallback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CloudProviderHeader(
              name: name, authenticateCallback: authenticateCallback),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return CloudProjectItem(project: projects[index]);
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }
}
