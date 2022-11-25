import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:takeoff_gui/common/icon_text_button.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/create/pages/create_dialog.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:takeoff_gui/features/quickstart/pages/quickstart_dialog.dart';

class SideBar extends StatelessWidget {
  final ProjectsController controller = GetIt.I.get<ProjectsController>();
  SideBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: DecoratedBox(
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 23, 112, 185)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    IconTextButton(
                      text: "Quickstart",
                      icon: Icons.rocket_launch,
                      onPressed: () => showDialog(
                        context: context,
                        builder: ((context) {
                          GetIt.I.get<QuickstartController>().resetForm();
                          return const QuickstartDialog();
                        }),
                      ),
                    ),
                    IconTextButton(
                      text: "Create",
                      icon: Icons.add_box,
                      onPressed: () => showDialog(
                        context: context,
                        builder: ((context) {
                          GetIt.I.get<CreateController>().resetForm();
                          return CreateDialog();
                        }),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const IconTextButton(
                      text: "CLI",
                      icon: Icons.terminal,
                    ),
                    IconTextButton(
                      text: "Clean",
                      icon: Icons.cleaning_services,
                      onPressed: () {
                        context.go("/");
                        controller.clean();
                      },
                    ),
                    IconTextButton(
                      text: "Home",
                      icon: Icons.home,
                      onPressed: () => context.go("/"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1, color: Colors.black),
      ],
    );
  }
}
