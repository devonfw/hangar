import 'package:flutter/material.dart';
import 'package:takeoff_gui/features/quickstart/utils/apps.dart';
import 'package:takeoff_gui/features/quickstart/widgets/quickstart_card.dart';
import 'package:takeoff_gui/features/quickstart/widgets/quickstart_form.dart';

class QuickstartDialog extends StatelessWidget {
  const QuickstartDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  QuickstartCard(
                    appImage: const AssetImage("assets/images/wayat_logo.png"),
                    technologiesImages: const [
                      AssetImage("assets/images/google_logo.png"),
                      AssetImage("assets/images/flutter_logo.png"),
                      AssetImage("assets/images/python_logo.png")
                    ],
                    appTypeSelect: Apps.wayat,
                  ),
                  QuickstartCard(
                    appImage: const AssetImage("assets/images/viplane_logo.png"),
                    technologiesImages: const [
                      AssetImage("assets/images/azure_logo.png"),
                      AssetImage("assets/images/angular_logo.png"),
                      AssetImage("assets/images/java_logo.png")
                    ],
                    appTypeSelect: Apps.viplane,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              QuickstartForm()
            ],
          ),
        ),
      ),
    );
  }
}
