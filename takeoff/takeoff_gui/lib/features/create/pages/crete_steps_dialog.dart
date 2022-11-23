import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/create/utils/type_message.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateStepsDialog extends StatelessWidget {
  final CreateController controller = GetIt.I.get<CreateController>();
  CreateStepsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            Observer(
              builder: (_) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text("Creating project...",
                      style: TextStyle(fontSize: 30)),
                  if (!controller.hasFinished)
                    const CircularProgressIndicator(),
                ],
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 600,
              width: 600,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
                child: Observer(
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: controller.createSteps.length,
                      itemBuilder: ((context, index) => Text(
                            controller.createSteps[index].message,
                            style: TextStyle(
                                color:
                                    controller.createSteps[index].typeMessage ==
                                            TypeMessage.info
                                        ? Colors.green
                                        : Colors.red),
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Observer(builder: (_) {
          if (controller.hasFinished) {
            return ElevatedButton(
                onPressed: () {
                  if (controller.isSuccess) {
                    launchUrl(Uri.parse(controller.projectUrl));
                    controller.projectUrl = "";
                  }
                  Navigator.of(context).pop();
                },
                child: Text(controller.isSuccess ? "Open project" : "Close"));
          }
          return Container();
        })
      ],
    );
  }
}
