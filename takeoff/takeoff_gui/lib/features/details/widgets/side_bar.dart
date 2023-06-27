import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:takeoff_gui/common/icon_text_button.dart';
import 'package:takeoff_gui/common/tooltip.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/create/pages/create_dialog.dart';
import 'package:takeoff_gui/features/details/widgets/clean_dialog.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:takeoff_gui/features/quickstart/pages/quickstart_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SideBar extends StatelessWidget {
  final ProjectsController controller = GetIt.I.get<ProjectsController>();
  SideBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          elevation: 10,
          child: Container(
            width: 80,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    TooltipMessage(
                      message:
                          AppLocalizations.of(context)!.quickStartButtonTooltip,
                      child: IconTextButton(
                        text: AppLocalizations.of(context)!.quickstartButton,
                        icon: Icons.rocket_launch,
                        onPressed: () => showDialog(
                          context: context,
                          builder: ((context) {
                            GetIt.I.get<QuickstartController>().resetForm();
                            return const QuickstartDialog();
                          }),
                        ),
                      ),
                    ),
                    TooltipMessage(
                      message:
                          AppLocalizations.of(context)!.createButtonTooltip,
                      child: IconTextButton(
                        text: AppLocalizations.of(context)!.createButton,
                        icon: Icons.add_box,
                        onPressed: () => showDialog(
                          context: context,
                          builder: ((context) {
                            GetIt.I.get<CreateController>().resetForm();
                            return CreateDialog();
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    TooltipMessage(
                      message: AppLocalizations.of(context)!.cliButtonTooltip,
                      child: IconTextButton(
                        text: AppLocalizations.of(context)!.cliButton,
                        icon: Icons.terminal,
                        onPressed: () => controller.openCLI(),
                      ),
                    ),
                    TooltipMessage(
                      message: AppLocalizations.of(context)!.cleanButtonTooltip,
                      child: IconTextButton(
                        text: AppLocalizations.of(context)!.cleanButton,
                        icon: Icons.cleaning_services,
                        onPressed: () => showDialog(
                          context: context,
                          builder: ((context) => CleanDialog()),
                        ),
                      ),
                    ),
                    TooltipMessage(
                      message: AppLocalizations.of(context)!.homeButtonTooltip,
                      child: IconTextButton(
                        text: AppLocalizations.of(context)!.homeButton,
                        icon: Icons.home,
                        onPressed: () => context.go("/"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        //const VerticalDivider(thickness: 1, width: 1, color: Colors.black),
      ],
    );
  }
}
