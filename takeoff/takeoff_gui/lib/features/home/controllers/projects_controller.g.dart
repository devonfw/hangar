// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProjectsController on _ProjectsController, Store {
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

  late final _$accountsAtom =
      Atom(name: '_ProjectsController.accounts', context: context);

  @override
  ObservableMap<String, String> get accounts {
    _$accountsAtom.reportRead();
    return super.accounts;
  }

  @override
  set accounts(ObservableMap<String, String> value) {
    _$accountsAtom.reportWrite(value, super.accounts, () {
      super.accounts = value;
    });
  }

  late final _$_ProjectsControllerActionController =
      ActionController(name: '_ProjectsController', context: context);

  @override
  void initAccount(String cloud) {
    final _$actionInfo = _$_ProjectsControllerActionController.startAction(
        name: '_ProjectsController.initAccount');
    try {
      return super.initAccount(cloud);
    } finally {
      _$_ProjectsControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateInitAccounts() {
    final _$actionInfo = _$_ProjectsControllerActionController.startAction(
        name: '_ProjectsController.updateInitAccounts');
    try {
      return super.updateInitAccounts();
    } finally {
      _$_ProjectsControllerActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
waitForToken: ${waitForToken},
accounts: ${accounts}
    ''';
  }
}

mixin _$FormLogin on _FormLogin, Store {
  late final _$waitForTokenAtom =
      Atom(name: '_FormLogin.waitForToken', context: context);

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

  @override
  String toString() {
    return '''
waitForToken: ${waitForToken}
    ''';
  }
}
