// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quickstart_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$QuickstartController on _QuickstartController, Store {
  Computed<bool>? _$isValidFormComputed;

  @override
  bool get isValidForm =>
      (_$isValidFormComputed ??= Computed<bool>(() => super.isValidForm,
              name: '_QuickstartController.isValidForm'))
          .value;

  late final _$appAtom =
      Atom(name: '_QuickstartController.app', context: context);

  @override
  Apps get app {
    _$appAtom.reportRead();
    return super.app;
  }

  @override
  set app(Apps value) {
    _$appAtom.reportWrite(value, super.app, () {
      super.app = value;
    });
  }

  late final _$billingAccountAtom =
      Atom(name: '_QuickstartController.billingAccount', context: context);

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

  late final _$regionAtom =
      Atom(name: '_QuickstartController.region', context: context);

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

  late final _$_QuickstartControllerActionController =
      ActionController(name: '_QuickstartController', context: context);

  @override
  void resetForm() {
    final _$actionInfo = _$_QuickstartControllerActionController.startAction(
        name: '_QuickstartController.resetForm');
    try {
      return super.resetForm();
    } finally {
      _$_QuickstartControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
app: ${app},
billingAccount: ${billingAccount},
region: ${region},
isValidForm: ${isValidForm}
    ''';
  }
}
