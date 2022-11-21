import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/create/utils/langauges_versions.dart';
import 'package:takeoff_gui/features/create/widgets/dropdown_field.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class FrontendForm extends StatelessWidget {
  final CreateController controller = GetIt.I.get<CreateController>();
  FrontendForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Frontend technology"),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Observer(
                  builder: (context) => DropdownField<Language>(
                        callback: controller.setFrontendLanguage,
                        dropdownValue: controller.frontendLanguage,
                        values: LanguagesVersions.frontendLanguages,
                      )),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Observer(
                  builder: (context) => DropdownField(
                        callback: (String? s) =>
                            controller.frontendVersion = s ?? "",
                        disable: controller.frontendLanguage == Language.none,
                        dropdownValue: controller.frontendVersion,
                        values: LanguagesVersions.versionsLanguages[
                                controller.frontendLanguage] ??
                            [] as List<String>,
                      )),
            ),
          ],
        ),
      ],
    );
  }
}
