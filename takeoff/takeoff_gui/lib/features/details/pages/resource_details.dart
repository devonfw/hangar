import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/details/widgets/resource_button.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_lib/src/utils/url_launcher/resource_type.dart';

class ResourceDetails extends StatelessWidget {
  ResourceDetails({super.key});
  final BoxBorder border = Border.all(color: Colors.black87, width: 2);
  final BoxBorder selectedBorder =
      Border.all(color: Colors.indigoAccent, width: 4);
  final double heignt = 70;
  final double width = 120;
  final ProjectsController controller = GetIt.I.get<ProjectsController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResourceButton(
            text: "Open IDE",
            onPressed: () => controller.openResource(ResourceType.ide)),
        const SizedBox(height: 20),
        ResourceButton(
            text: "Open Pipeline",
            onPressed: () => controller.openResource(ResourceType.pipeline)),
        const SizedBox(height: 20),
        ResourceButton(
            text: "Open Frontend Repo",
            onPressed: () => controller.openResource(ResourceType.frontend)),
        const SizedBox(height: 20),
        ResourceButton(
            text: "Open Backend Repo",
            onPressed: () => controller.openResource(ResourceType.backend)),
      ],
    );
  }
}
