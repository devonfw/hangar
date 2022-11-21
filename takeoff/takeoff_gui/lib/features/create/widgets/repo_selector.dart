import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';

class RepoSelector extends StatelessWidget {
  final BoxBorder border = Border.all(color: Colors.grey, width: 3);
  final BoxBorder selectedBorder =
      Border.all(color: Colors.indigoAccent, width: 5);
  final double squareSize = 130;
  final CreateController controller = GetIt.I.get<CreateController>();
  RepoSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select a repo & CI/CD provider"),
        const SizedBox(height: 15),
        Row(
          children: [
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.repoProvider == "Google"
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage("assets/images/google_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.repoProvider = "Google",
            ),
            const SizedBox(width: 20),
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.repoProvider == "AzureDevOps"
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image:
                            AssetImage("assets/images/azure_devops_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.repoProvider = "AzureDevOps",
            ),
            const SizedBox(width: 20),
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.repoProvider == "Github"
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage("assets/images/github_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.repoProvider = "Github",
            ),
          ],
        ),
      ],
    );
  }
}
