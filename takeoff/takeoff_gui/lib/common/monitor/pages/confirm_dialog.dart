import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:url_launcher/url_launcher.dart';

class UserInteractionDialog extends StatelessWidget {
  final GuiMessage message;
  final MonitorController controller = GetIt.I.get<MonitorController>();
  final TextEditingController textController = TextEditingController();
  UserInteractionDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text(
                    "Please, do next steps",
                    style: TextStyle(fontSize: 30),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Text(message.message),
              const SizedBox(height: 10),
              if (message.inputType != null)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        inputFormatters: message.inputType == InputType.number
                            ? [FilteringTextInputFormatter.digitsOnly]
                            : [],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
      actions: [
        if (message.url != null)
          CustomButton(
            text: "Open link",
            icon: Icons.check_box,
            onPressed: () {
              launchUrl(Uri.parse(message.url!));
            },
          ),
        CustomButton(
          text: "Confirm",
          icon: Icons.check_box,
          onPressed: () {
            if (message.inputType != null) {
              controller.inputChannel.add(textController.text.trim());
            } else if (message.url != null) {
              controller.inputChannel.add("true");
            }
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
