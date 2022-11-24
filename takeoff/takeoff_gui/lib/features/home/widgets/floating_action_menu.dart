import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/pages/create_dialog.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/home/widgets/custom_floating_button.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:takeoff_gui/features/quickstart/pages/quickstart_dialog.dart';

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
          builder: (_) => CustomFloatingButton(
            icon: Icons.add_box_outlined,
            onPressed: controller.isLogged
                ? () => showDialog(
                      context: context,
                      builder: ((context) => CreateDialog()),
                      barrierDismissible: false,
                    )
                : null,
            text: "Create",
          ),
        ),
        const SizedBox(width: 10),
        Observer(
          builder: (_) => CustomFloatingButton(
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
            text: "QuickStart",
          ),
        ),
      ],
    );
  }
}
