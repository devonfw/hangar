import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:takeoff_gui/features/quickstart/utils/apps.dart';

class QuickstartCard extends StatelessWidget {
  final BoxBorder border = Border.all(color: Colors.grey, width: 3);
  final BoxBorder selectedBorder =
      Border.all(color: Colors.indigoAccent, width: 5);
  final double squareSize = 130;
  final QuickstartController controller = GetIt.I.get<QuickstartController>();
  final ImageProvider<Object> appImage;
  final List<ImageProvider<Object>> technologiesImages;
  final Apps appTypeSelect;
  QuickstartCard(
      {super.key,
      required this.appImage,
      required this.technologiesImages,
      required this.appTypeSelect});

  @override
  Widget build(BuildContext context) {
    List<Widget> rowChildren = [];
    for (ImageProvider<Object> image in technologiesImages) {
      rowChildren.add(
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            image: DecorationImage(fit: BoxFit.contain, image: image),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Observer(
        builder: (_) => GestureDetector(
          child: SizedBox(
            height: 250,
            width: 250,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border:
                    controller.app == appTypeSelect ? selectedBorder : border,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 150,
                    decoration: BoxDecoration(
                      image:
                          DecorationImage(fit: BoxFit.contain, image: appImage),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: rowChildren,
                  )
                ],
              ),
            ),
          ),
          onTap: () {
            if (controller.app != appTypeSelect) {
              controller.resetForm();
              controller.app = appTypeSelect;
            }
          },
        ),
      ),
    );
  }
}
