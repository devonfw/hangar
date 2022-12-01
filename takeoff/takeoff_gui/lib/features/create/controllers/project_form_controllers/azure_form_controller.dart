import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:takeoff_gui/features/create/controllers/project_form_controllers/create_form_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

part 'azure_form_controller.g.dart';

// ignore: library_private_types_in_public_api
class AzureFormController = _AzureFormController with _$AzureFormController;

abstract class _AzureFormController with Store implements CreateFormController {
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();

  @override
  Future<void> create({
    Language? backendLanguage,
    String? backendVersion,
    Language? frontendLanguage,
    String? frontendVersion,
    StreamController<GuiMessage>? infoStream,
    StreamController<String>? inputStream,
  }) {
    return Future.value();
  }

  @computed
  @override
  bool get isValid => false;

  @action
  @override
  void resetForm() {}
}
