// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quickstart_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$QuickstartController on _QuickstartController, Store {
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

  @override
  String toString() {
    return '''
app: ${app}
    ''';
  }
}
