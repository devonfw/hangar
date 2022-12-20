import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:takeoff_gui/features/create/widgets/project_forms/project_forms.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class ProjectForm extends StatelessWidget {
  final CreateController controller = GetIt.I.get<CreateController>();
  ProjectForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      switch (controller.cloudProvider) {
        case CloudProviderId.gcloud:
          return GoogleForm();
        case CloudProviderId.aws:
          return AwsForm();
        case CloudProviderId.azure:
          return AzureForm();
      }
    });
  }
}
