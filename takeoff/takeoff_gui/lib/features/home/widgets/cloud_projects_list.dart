import 'package:flutter/material.dart';
import 'package:takeoff_gui/domain/project.dart';

class CloudProjectsList extends StatelessWidget {
  final String name;
  final List<Project> projects;
  final Function authenticateCallback;
  const CloudProjectsList(
      {super.key,
      required this.name,
      required this.projects,
      required this.authenticateCallback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(children: [
            Text(name),
            IconButton(
              icon: const Icon(Icons.login_outlined),
              splashRadius: 16,
              onPressed: () => authenticateCallback(),
            )
          ]),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 200,
                  width: 200,
                  child: GestureDetector(
                    child: Card(
                      child: Text(projects[index].name),
                    ),
                    onTap: () =>
                        print("pressed project ${projects[index].name}"),
                  ),
                );
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }
}
