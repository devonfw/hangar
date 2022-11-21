// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CreateController on _CreateController, Store {
  late final _$cloudProviderAtom =
      Atom(name: '_CreateController.cloudProvider', context: context);

  @override
  String get cloudProvider {
    _$cloudProviderAtom.reportRead();
    return super.cloudProvider;
  }

  @override
  set cloudProvider(String value) {
    _$cloudProviderAtom.reportWrite(value, super.cloudProvider, () {
      super.cloudProvider = value;
    });
  }

  late final _$repoProviderAtom =
      Atom(name: '_CreateController.repoProvider', context: context);

  @override
  String get repoProvider {
    _$repoProviderAtom.reportRead();
    return super.repoProvider;
  }

  @override
  set repoProvider(String value) {
    _$repoProviderAtom.reportWrite(value, super.repoProvider, () {
      super.repoProvider = value;
    });
  }

  late final _$projectNameAtom =
      Atom(name: '_CreateController.projectName', context: context);

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

  late final _$billingAccountAtom =
      Atom(name: '_CreateController.billingAccount', context: context);

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

  late final _$frontendLanguageAtom =
      Atom(name: '_CreateController.frontendLanguage', context: context);

  @override
  String get frontendLanguage {
    _$frontendLanguageAtom.reportRead();
    return super.frontendLanguage;
  }

  @override
  set frontendLanguage(String value) {
    _$frontendLanguageAtom.reportWrite(value, super.frontendLanguage, () {
      super.frontendLanguage = value;
    });
  }

  late final _$frontendVersionAtom =
      Atom(name: '_CreateController.frontendVersion', context: context);

  @override
  String get frontendVersion {
    _$frontendVersionAtom.reportRead();
    return super.frontendVersion;
  }

  @override
  set frontendVersion(String value) {
    _$frontendVersionAtom.reportWrite(value, super.frontendVersion, () {
      super.frontendVersion = value;
    });
  }

  late final _$backendLanguageAtom =
      Atom(name: '_CreateController.backendLanguage', context: context);

  @override
  String get backendLanguage {
    _$backendLanguageAtom.reportRead();
    return super.backendLanguage;
  }

  @override
  set backendLanguage(String value) {
    _$backendLanguageAtom.reportWrite(value, super.backendLanguage, () {
      super.backendLanguage = value;
    });
  }

  late final _$backendVersionAtom =
      Atom(name: '_CreateController.backendVersion', context: context);

  @override
  String get backendVersion {
    _$backendVersionAtom.reportRead();
    return super.backendVersion;
  }

  @override
  set backendVersion(String value) {
    _$backendVersionAtom.reportWrite(value, super.backendVersion, () {
      super.backendVersion = value;
    });
  }

  @override
  String toString() {
    return '''
cloudProvider: ${cloudProvider},
repoProvider: ${repoProvider},
projectName: ${projectName},
billingAccount: ${billingAccount},
frontendLanguage: ${frontendLanguage},
frontendVersion: ${frontendVersion},
backendLanguage: ${backendLanguage},
backendVersion: ${backendVersion}
    ''';
  }
}
