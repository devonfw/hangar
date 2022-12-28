import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserInteractionDialog extends StatefulWidget {
  final GuiMessage message;

  const UserInteractionDialog({super.key, required this.message});

  @override
  State<UserInteractionDialog> createState() => _UserInteractionDialogState();
}

class _UserInteractionDialogState extends State<UserInteractionDialog> {
  final MonitorController controller = GetIt.I.get<MonitorController>();

  final TextEditingController textController = TextEditingController();
  late bool linkTapped;

  @override
  void initState() {
    linkTapped = widget.message.url == null;
    super.initState();
  }

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
                children: [
                  Text(
                    AppLocalizations.of(context)!.followStepsMessage,
                    style: const TextStyle(fontSize: 30),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              SelectableText(
                widget.message.message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (widget.message.inputType != null)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        inputFormatters:
                            widget.message.inputType == InputType.number
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
        if (widget.message.url != null)
          CustomButton(
            text: AppLocalizations.of(context)!.openLink,
            icon: Icons.check_box,
            onPressed: () {
              launchUrl(Uri.parse(widget.message.url!));
              setState(() {
                linkTapped = true;
              });
            },
          ),
        CustomButton(
          text: AppLocalizations.of(context)!.confirm,
          icon: Icons.check_box,
          onPressed: (linkTapped)
              ? () {
                  if (widget.message.inputType != null) {
                    controller.inputChannel.add(textController.text);
                  } else if (widget.message.url != null) {
                    controller.inputChannel.add("true");
                  }
                  Navigator.of(context).pop();
                }
              : null,
        )
      ],
    );
  }
}
