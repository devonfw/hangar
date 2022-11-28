import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/domain/project.dart';
import 'package:takeoff_gui/features/details/widgets/side_bar.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';

class ProjectDetails extends StatelessWidget {
  final Project project = GetIt.I.get<ProjectsController>().selectedProject!;
  ProjectDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideBar(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO add dropdown to select project here
                const SizedBox(height: 40),
                Text(
                  "${project.name} project resources",
                  style: const TextStyle(fontSize: 30),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
