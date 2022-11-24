// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitor_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MonitorController on _MonitorController, Store {
  Computed<bool>? _$hasFinishedComputed;

  @override
  bool get hasFinished =>
      (_$hasFinishedComputed ??= Computed<bool>(() => super.hasFinished,
              name: '_MonitorController.hasFinished'))
          .value;

  late final _$stepsAtom =
      Atom(name: '_MonitorController.steps', context: context);

  @override
  ObservableList<CreateMessage> get steps {
    _$stepsAtom.reportRead();
    return super.steps;
  }

  @override
  set steps(ObservableList<CreateMessage> value) {
    _$stepsAtom.reportWrite(value, super.steps, () {
      super.steps = value;
    });
  }

  late final _$projectUrlAtom =
      Atom(name: '_MonitorController.projectUrl', context: context);

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

  @override
  String toString() {
    return '''
steps: ${steps},
projectUrl: ${projectUrl},
hasFinished: ${hasFinished}
    ''';
  }
}
