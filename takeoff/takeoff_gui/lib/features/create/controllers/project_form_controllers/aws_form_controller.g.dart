// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aws_form_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AwsFormController on _AwsFormController, Store {
  Computed<bool>? _$isValidComputed;

  @override
  bool get isValid => (_$isValidComputed ??= Computed<bool>(() => super.isValid,
          name: '_AwsFormController.isValid'))
      .value;

  late final _$_AwsFormControllerActionController =
      ActionController(name: '_AwsFormController', context: context);

  @override
  void resetForm() {
    final _$actionInfo = _$_AwsFormControllerActionController.startAction(
        name: '_AwsFormController.resetForm');
    try {
      return super.resetForm();
    } finally {
      _$_AwsFormControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isValid: ${isValid}
    ''';
  }
}
