// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CreateController on _CreateController, Store {
  Computed<List<ProviderCICD>>? _$providersCICDComputed;

  @override
  List<ProviderCICD> get providersCICD => (_$providersCICDComputed ??=
          Computed<List<ProviderCICD>>(() => super.providersCICD,
              name: '_CreateController.providersCICD'))
      .value;
  Computed<bool>? _$hasFinishedComputed;

  @override
  bool get hasFinished =>
      (_$hasFinishedComputed ??= Computed<bool>(() => super.hasFinished,
              name: '_CreateController.hasFinished'))
          .value;

  late final _$cloudProviderAtom =
      Atom(name: '_CreateController.cloudProvider', context: context);

  @override
  CloudProviderId get cloudProvider {
    _$cloudProviderAtom.reportRead();
    return super.cloudProvider;
  }

  @override
  set cloudProvider(CloudProviderId value) {
    _$cloudProviderAtom.reportWrite(value, super.cloudProvider, () {
      super.cloudProvider = value;
    });
  }

  late final _$repoProviderAtom =
      Atom(name: '_CreateController.repoProvider', context: context);

  @override
  ProviderCICD get repoProvider {
    _$repoProviderAtom.reportRead();
    return super.repoProvider;
  }

  @override
  set repoProvider(ProviderCICD value) {
    _$repoProviderAtom.reportWrite(value, super.repoProvider, () {
      super.repoProvider = value;
    });
  }

  late final _$createStepsAtom =
      Atom(name: '_CreateController.createSteps', context: context);

  @override
  ObservableList<CreateMessage> get createSteps {
    _$createStepsAtom.reportRead();
    return super.createSteps;
  }

  @override
  set createSteps(ObservableList<CreateMessage> value) {
    _$createStepsAtom.reportWrite(value, super.createSteps, () {
      super.createSteps = value;
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

  late final _$projectUrlAtom =
      Atom(name: '_CreateController.projectUrl', context: context);

  @override
  String get projectUrl {
    _$projectUrlAtom.reportRead();
    return super.projectUrl;
  }

  @override
  set projectUrl(String value) {
    _$projectUrlAtom.reportWrite(value, super.projectUrl, () {
      super.projectUrl = value;
    });
  }

  late final _$regionAtom =
      Atom(name: '_CreateController.region', context: context);

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
  Language get frontendLanguage {
    _$frontendLanguageAtom.reportRead();
    return super.frontendLanguage;
  }

  @override
  set frontendLanguage(Language value) {
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
  Language get backendLanguage {
    _$backendLanguageAtom.reportRead();
    return super.backendLanguage;
  }

  @override
  set backendLanguage(Language value) {
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

  late final _$googleCloudRegionAtom =
      Atom(name: '_CreateController.googleCloudRegion', context: context);

  @override
  String get googleCloudRegion {
    _$googleCloudRegionAtom.reportRead();
    return super.googleCloudRegion;
  }

  @override
  set googleCloudRegion(String value) {
    _$googleCloudRegionAtom.reportWrite(value, super.googleCloudRegion, () {
      super.googleCloudRegion = value;
    });
  }

  late final _$_CreateControllerActionController =
      ActionController(name: '_CreateController', context: context);

  @override
  void setCloudProvider(CloudProviderId cloud) {
    final _$actionInfo = _$_CreateControllerActionController.startAction(
        name: '_CreateController.setCloudProvider');
    try {
      return super.setCloudProvider(cloud);
    } finally {
      _$_CreateControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFrontendLanguage(Language lang) {
    final _$actionInfo = _$_CreateControllerActionController.startAction(
        name: '_CreateController.setFrontendLanguage');
    try {
      return super.setFrontendLanguage(lang);
    } finally {
      _$_CreateControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setBackendLanguage(Language lang) {
    final _$actionInfo = _$_CreateControllerActionController.startAction(
        name: '_CreateController.setBackendLanguage');
    try {
      return super.setBackendLanguage(lang);
    } finally {
      _$_CreateControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetForm() {
    final _$actionInfo = _$_CreateControllerActionController.startAction(
        name: '_CreateController.resetForm');
    try {
      return super.resetForm();
    } finally {
      _$_CreateControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cloudProvider: ${cloudProvider},
repoProvider: ${repoProvider},
createSteps: ${createSteps},
projectName: ${projectName},
projectUrl: ${projectUrl},
region: ${region},
billingAccount: ${billingAccount},
frontendLanguage: ${frontendLanguage},
frontendVersion: ${frontendVersion},
backendLanguage: ${backendLanguage},
backendVersion: ${backendVersion},
googleCloudRegion: ${googleCloudRegion},
providersCICD: ${providersCICD},
hasFinished: ${hasFinished}
    ''';
  }
}
