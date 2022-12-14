import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_lib/src/utils/url_launcher/resource_type.dart';

class ResourceDetails extends StatelessWidget {
  ResourceDetails({super.key});
  final BoxBorder border = Border.all(color: Colors.black87, width: 2);
  final BoxBorder selectedBorder =
      Border.all(color: Colors.indigoAccent, width: 4);
  final ProjectsController controller = GetIt.I.get<ProjectsController>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomButton(
              text: "Open IDE",
              onPressed: () => controller.openResource(ResourceType.ide),
              icon: Icons.code),
          const SizedBox(height: 20),
          CustomButton(
              text: "Open Pipeline",
              onPressed: () => controller.openResource(ResourceType.pipeline),
              icon: Icons.cloud_sync_outlined),
          const SizedBox(height: 20),
          CustomButton(
              text: "Open FE Repo",
              onPressed: () => controller.openResource(ResourceType.frontend),
              icon: Icons.account_tree_outlined),
          const SizedBox(height: 20),
          CustomButton(
              text: "Open BE Repo",
              onPressed: () => controller.openResource(ResourceType.backend),
              icon: Icons.account_tree_outlined),
        ],
      ),
    );
  }
}
