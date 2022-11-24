import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class CloudSelector extends StatelessWidget {
  final BoxBorder border = Border.all(color: Colors.grey, width: 3);
  final BoxBorder selectedBorder =
      Border.all(color: Colors.indigoAccent, width: 5);
  final double squareSize = 130;
  final CreateController controller = GetIt.I.get<CreateController>();
  CloudSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select a cloud provider"),
        const SizedBox(height: 15),
        Row(
          children: [
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.cloudProvider == CloudProviderId.gcloud
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image:
                            AssetImage("assets/images/google_cloud_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.setCloudProvider(CloudProviderId.gcloud),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.cloudProvider == CloudProviderId.aws
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage("assets/images/aws_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.setCloudProvider(CloudProviderId.aws),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              child: Observer(
                builder: (_) => Container(
                  height: squareSize,
                  width: squareSize,
                  decoration: BoxDecoration(
                    border: controller.cloudProvider == CloudProviderId.azure
                        ? selectedBorder
                        : border,
                    image: const DecorationImage(
                        fit: BoxFit.scaleDown,
                        image: AssetImage("assets/images/azure_logo.png")),
                  ),
                ),
              ),
              onTap: () => controller.setCloudProvider(CloudProviderId.azure),
            ),
          ],
        ),
      ],
    );
  }
}
