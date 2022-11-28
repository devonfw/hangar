import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:takeoff_gui/domain/project.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';

class CloudProjectItem extends StatelessWidget {
  final ProjectsController controller = GetIt.I.get<ProjectsController>();
  CloudProjectItem({
    Key? key,
    required this.project,
  }) : super(key: key);

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 200,
        width: 200,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Card(
              child: Center(child: Text(project.name)),
            ),
            onTap: () {
              controller.selectedProject = project;
              context.go("/project/${project.cloud}/${project.name}");
            },
          ),
        ),
      ),
    );
  }
}
