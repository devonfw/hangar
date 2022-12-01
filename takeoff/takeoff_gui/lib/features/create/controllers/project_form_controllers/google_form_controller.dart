import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/create_form_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

part 'google_form_controller.g.dart';

// ignore: library_private_types_in_public_api
class GoogleFormController = _GoogleFormController with _$GoogleFormController;

abstract class _GoogleFormController
    with Store
    implements CreateFormController {
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();

  @observable
  String projectName = "";

  @observable
  String region = "";

  @observable
  String billingAccount = "";

  @override
  Future<void> create({
    Language? backendLanguage,
    String? backendVersion,
    Language? frontendLanguage,
    String? frontendVersion,
    StreamController<GuiMessage>? infoStream,
    StreamController<String>? inputStream,
  }) {
    return facade.createProjectGCloud(
        projectName: projectName,
        billingAccount: billingAccount,
        backendLanguage: backendLanguage,
        backendVersion: backendVersion,
        frontendLanguage: frontendLanguage,
        frontendVersion: frontendVersion,
        googleCloudRegion: region,
        infoStream: infoStream,
        inputStream: inputStream);
  }

  @computed
  @override
  bool get isValid =>
      projectName.isNotEmpty && billingAccount.isNotEmpty && region.isNotEmpty;

  @action
  @override
  void resetForm() {
    projectName = "";
    billingAccount = "";
    region = "";
  }
}
