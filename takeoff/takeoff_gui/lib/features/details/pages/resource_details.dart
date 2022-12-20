import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              text: AppLocalizations.of(context)!.openIdeButton,
              onPressed: () => controller.openResource(Resource.ide),
              icon: Icons.code),
          const SizedBox(height: 20),
          CustomButton(
              text: AppLocalizations.of(context)!.openPipelineButton,
              onPressed: () => controller.openResource(Resource.pipeline),
              icon: Icons.cloud_sync_outlined),
          const SizedBox(height: 20),
          CustomButton(
              text: AppLocalizations.of(context)!.openFeRepo,
              onPressed: () => controller.openResource(Resource.feRepo),
              icon: Icons.account_tree_outlined),
          const SizedBox(height: 20),
          CustomButton(
              text: AppLocalizations.of(context)!.openBeRepo,
              onPressed: () => controller.openResource(Resource.beRepo),
              icon: Icons.account_tree_outlined),
        ],
      ),
    );
  }
}
