// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_form_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GoogleFormController on _GoogleFormController, Store {
  Computed<bool>? _$isValidComputed;

  @override
  bool get isValid => (_$isValidComputed ??= Computed<bool>(() => super.isValid,
          name: '_GoogleFormController.isValid'))
      .value;

  late final _$projectNameAtom =
      Atom(name: '_GoogleFormController.projectName', context: context);

  @override
  String get projectName {
    _$projectNameAtom.reportRead();
    return super.projectName;
  }

  @override
  set projectName(String value) {
    _$projectNameAtom.reportWrite(value, super.projectName, () {
      super.projectName = value;
    });
  }

  late final _$regionAtom =
      Atom(name: '_GoogleFormController.region', context: context);

  @override
  String get region {
    _$regionAtom.reportRead();
    return super.region;
  }

  @override
  set region(String value) {
    _$regionAtom.reportWrite(value, super.region, () {
      super.region = value;
    });
  }

  late final _$billingAccountAtom =
      Atom(name: '_GoogleFormController.billingAccount', context: context);

  @override
  String get billingAccount {
    _$billingAccountAtom.reportRead();
    return super.billingAccount;
  }

  @override
  set billingAccount(String value) {
    _$billingAccountAtom.reportWrite(value, super.billingAccount, () {
      super.billingAccount = value;
    });
  }

  late final _$_GoogleFormControllerActionController =
      ActionController(name: '_GoogleFormController', context: context);

  @override
  void resetForm() {
    final _$actionInfo = _$_GoogleFormControllerActionController.startAction(
        name: '_GoogleFormController.resetForm');
    try {
      return super.resetForm();
    } finally {
      _$_GoogleFormControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
projectName: ${projectName},
region: ${region},
billingAccount: ${billingAccount},
isValid: ${isValid}
    ''';
  }
}
