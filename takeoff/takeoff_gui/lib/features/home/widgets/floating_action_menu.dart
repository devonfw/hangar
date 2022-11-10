import 'package:flutter/material.dart';
import 'package:takeoff_gui/features/home/widgets/custom_floating_button.dart';

class FloatingActionMenu extends StatelessWidget {
  const FloatingActionMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomFloatingButton(
          icon: Icons.add_box_outlined,
          onPressed: () => print("Create!"),
          text: "Create",
        ),
        const SizedBox(width: 10),
        CustomFloatingButton(
          icon: Icons.rocket_launch,
          onPressed: () => print("QuickStart!"),
          text: "QuickStart",
        ),
      ],
    );
  }
}
