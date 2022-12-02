import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';

class ResourceDetails extends StatelessWidget {
  ResourceDetails({super.key});
  final BoxBorder border = Border.all(color: Colors.black87, width: 2);
  final BoxBorder selectedBorder =
      Border.all(color: Colors.indigoAccent, width: 4);
  final double heignt = 70;
  final double width = 100;
  final ProjectsController controller = GetIt.I.get<ProjectsController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: (() {
            controller.openIDE();
          }),
          child: Observer(
            builder: (_) => Container(
              height: heignt,
              width: width,
              decoration: BoxDecoration(border: border),
              child: const Center(
                child: Text(
                  "Open IDE",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            controller.openPipeline();
          },
          child: Observer(
            builder: (_) => Container(
              height: heignt,
              width: width,
              decoration: BoxDecoration(border: border),
              child: const Center(
                child: Text(
                  "Open Pipelines",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            controller.openFrontendRepo();
          },
          child: Observer(
            builder: (_) => Container(
              height: heignt,
              width: width,
              decoration: BoxDecoration(
                border: border,
              ),
              child: const Center(
                child: Text(
                  "Open Frontend Repo",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            controller.openBackendRepo();
          },
          child: Observer(
            builder: (_) => Container(
              height: heignt,
              width: width,
              decoration: BoxDecoration(
                border: border,
              ),
              child: const Center(
                child: Text("Open Backend Repo",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
