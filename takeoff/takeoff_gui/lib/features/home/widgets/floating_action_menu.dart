import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/common/tooltip.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/create/pages/create_dialog.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/common/custom_button.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:takeoff_gui/features/quickstart/pages/quickstart_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FloatingActionMenu extends StatelessWidget {
  final ProjectsController controller = GetIt.I.get<ProjectsController>();
  FloatingActionMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Observer(
          builder: (_) => TooltipMessage(
            message: AppLocalizations.of(context)!.createButtonTooltip,
            child: CustomButton(
                icon: Icons.add_box_outlined,
                onPressed: controller.isLogged
                    ? () => showDialog(
                          context: context,
                          builder: ((context) {
                            GetIt.I.get<CreateController>().resetForm();
                            return CreateDialog();
                          }),
                          barrierDismissible: false,
                        )
                    : null,
                text: AppLocalizations.of(context)!.createButton),
          ),
        ),
        const SizedBox(width: 10),
        Observer(
          builder: (_) => TooltipMessage(
            message: AppLocalizations.of(context)!.quickStartButtonTooltip,
            child: CustomButton(
              icon: Icons.rocket_launch,
              onPressed: controller.isLogged
                  ? () => showDialog(
                        context: context,
                        builder: ((context) {
                          GetIt.I.get<QuickstartController>().resetForm();
                          return const QuickstartDialog();
                        }),
                      )
                  : null,
              text: AppLocalizations.of(context)!.quickstartButton,
            ),
          ),
        ),
      ],
    );
  }
}
