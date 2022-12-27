import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_gui/common/monitor/pages/user_interaction_dialog.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MonitorDialog extends StatelessWidget {
  final MonitorController controller = GetIt.I.get<MonitorController>();
  MonitorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: controller.outputChannel.stream,
        builder: (context, snapshot) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (snapshot.hasData) {
              _generateDialog(snapshot.data as GuiMessage, context);
            }
          });
          return AlertDialog(
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Observer(
                      builder: (_) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                              controller.hasFinished
                                  ? AppLocalizations.of(context)!
                                      .projectCreationIsFinishMessage
                                  : AppLocalizations.of(context)!
                                      .creatingProjectMessage,
                              style: const TextStyle(fontSize: 30)),
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
                              itemCount: controller.steps.length,
                              itemBuilder: ((context, index) => Text(
                                    controller.steps[index].message,
                                    style: TextStyle(
                                        color: controller
                                            .steps[index].typeMessage.color),
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Observer(builder: (_) {
                if (controller.hasFinished) {
                  return CustomButton(
                      onPressed: () {
                        if (controller.isSuccess) {
                          launchUrl(Uri.parse(controller.projectUrl));
                          controller.projectUrl = "";
                          GetIt.I
                              .get<ProjectsController>()
                              .updateInitAccounts();
                        }
                        controller.resetChannel();
                        Navigator.of(context).pop();
                      },
                      icon: Icons.browser_updated_outlined,
                      text: controller.isSuccess
                          ? AppLocalizations.of(context)!.openProjectButton
                          : AppLocalizations.of(context)!.closeButton);
                }
                return Container();
              })
            ],
          );
        });
  }

  _generateDialog(GuiMessage message, BuildContext context) {
    switch (message.type) {
      case MessageType.info:
        break;
      case MessageType.error:
        break;
      case MessageType.success:
        break;
      case MessageType.input:
      case MessageType.browser:
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => UserInteractionDialog(message: message),
        );
        break;
    }
  }
}
