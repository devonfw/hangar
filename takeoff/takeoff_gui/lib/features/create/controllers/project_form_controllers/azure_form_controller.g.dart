// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azure_form_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AzureFormController on _AzureFormController, Store {
  Computed<bool>? _$isValidComputed;

  @override
  bool get isValid => (_$isValidComputed ??= Computed<bool>(() => super.isValid,
          name: '_AzureFormController.isValid'))
      .value;

  late final _$_AzureFormControllerActionController =
      ActionController(name: '_AzureFormController', context: context);

  @override
  void resetForm() {
    final _$actionInfo = _$_AzureFormControllerActionController.startAction(
        name: '_AzureFormController.resetForm');
    try {
      return super.resetForm();
    } finally {
      _$_AzureFormControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isValid: ${isValid}
    ''';
  }
}
