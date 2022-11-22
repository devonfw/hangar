import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/create/utils/languages_versions.dart';
import 'package:takeoff_gui/features/create/widgets/dropdown_field.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class BackendForm extends StatelessWidget {
  final CreateController controller = GetIt.I.get<CreateController>();
  BackendForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Backend technology"),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Observer(
                  builder: (context) => DropdownField(
                        callback: controller.setBackendLanguage,
                        dropdownValue: controller.backendLanguage,
                        values: LanguagesVersions.backendLanguages,
                      )),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Observer(
                  builder: (context) => DropdownField(
                        callback: (String? s) =>
                            controller.backendVersion = s ?? "",
                        disable: controller.backendLanguage == Language.none,
                        dropdownValue: controller.backendVersion,
                        values: LanguagesVersions.versionsLanguages[
                                controller.backendLanguage] ??
                            [] as List<String>,
                      )),
            ),
          ],
        ),
      ],
    );
  }
}
