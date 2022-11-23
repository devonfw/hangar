// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProjectsController on _ProjectsController, Store {
  Computed<bool>? _$isLoggedComputed;

  @override
  bool get isLogged =>
      (_$isLoggedComputed ??= Computed<bool>(() => super.isLogged,
              name: '_ProjectsController.isLogged'))
          .value;

  late final _$waitForTokenAtom =
      Atom(name: '_ProjectsController.waitForToken', context: context);

  @override
  bool get waitForToken {
    _$waitForTokenAtom.reportRead();
    return super.waitForToken;
  }

  @override
  set waitForToken(bool value) {
    _$waitForTokenAtom.reportWrite(value, super.waitForToken, () {
      super.waitForToken = value;
    });
  }

  late final _$projectsAtom =
      Atom(name: '_ProjectsController.projects', context: context);

  @override
  ObservableMap<CloudProviderId, List<Project>> get projects {
    _$projectsAtom.reportRead();
    return super.projects;
  }

  @override
  set projects(ObservableMap<CloudProviderId, List<Project>> value) {
    _$projectsAtom.reportWrite(value, super.projects, () {
      super.projects = value;
    });
  }

  late final _$accountsAtom =
      Atom(name: '_ProjectsController.accounts', context: context);

  @override
  ObservableMap<CloudProviderId, String> get accounts {
    _$accountsAtom.reportRead();
    return super.accounts;
  }

  @override
  set accounts(ObservableMap<CloudProviderId, String> value) {
    _$accountsAtom.reportWrite(value, super.accounts, () {
      super.accounts = value;
    });
  }

  late final _$updateInitAccountsAsyncAction =
      AsyncAction('_ProjectsController.updateInitAccounts', context: context);

  @override
  Future<void> updateInitAccounts() {
    return _$updateInitAccountsAsyncAction
        .run(() => super.updateInitAccounts());
  }

  late final _$_ProjectsControllerActionController =
      ActionController(name: '_ProjectsController', context: context);

  @override
  Future<bool> initAccount(String email, CloudProviderId cloud) {
    final _$actionInfo = _$_ProjectsControllerActionController.startAction(
        name: '_ProjectsController.initAccount');
    try {
      return super.initAccount(email, cloud);
    } finally {
      _$_ProjectsControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
waitForToken: ${waitForToken},
projects: ${projects},
accounts: ${accounts},
isLogged: ${isLogged}
    ''';
  }
}
