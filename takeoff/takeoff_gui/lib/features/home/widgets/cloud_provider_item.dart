import 'package:flutter/material.dart';
import 'package:takeoff_gui/domain/project.dart';

class CloudProjectItem extends StatelessWidget {
  const CloudProjectItem({
    Key? key,
    required this.project,
  }) : super(key: key);

  final Project project;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: GestureDetector(
        child: Card(
          child: Center(child: Text(project.name)),
        ),
        onTap: () => print("pressed project ${project.name}"),
      ),
    );
  }
}
