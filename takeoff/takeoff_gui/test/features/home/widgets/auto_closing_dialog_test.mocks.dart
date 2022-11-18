// Mocks generated by Mockito 5.3.2 from annotations
// in takeoff_gui/test/features/home/widgets/auto_closing_dialog_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mobx/mobx.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart'
    as _i5;
import 'package:takeoff_lib/takeoff_lib.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeTakeOffFacade_0 extends _i1.SmartFake implements _i2.TakeOffFacade {
  _FakeTakeOffFacade_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamController_1<T> extends _i1.SmartFake
    implements _i3.StreamController<T> {
  _FakeStreamController_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeObservableMap_2<K, V> extends _i1.SmartFake
    implements _i4.ObservableMap<K, V> {
  _FakeObservableMap_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeReactiveContext_3 extends _i1.SmartFake
    implements _i4.ReactiveContext {
  _FakeReactiveContext_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ProjectsController].
///
/// See the documentation for Mockito's code generation for more information.
class MockProjectsController extends _i1.Mock
    implements _i5.ProjectsController {
  @override
  _i2.TakeOffFacade get facade => (super.noSuchMethod(
        Invocation.getter(#facade),
        returnValue: _FakeTakeOffFacade_0(
          this,
          Invocation.getter(#facade),
        ),
        returnValueForMissingStub: _FakeTakeOffFacade_0(
          this,
          Invocation.getter(#facade),
        ),
      ) as _i2.TakeOffFacade);
  @override
  _i3.StreamController<List<int>> get channel => (super.noSuchMethod(
        Invocation.getter(#channel),
        returnValue: _FakeStreamController_1<List<int>>(
          this,
          Invocation.getter(#channel),
        ),
        returnValueForMissingStub: _FakeStreamController_1<List<int>>(
          this,
          Invocation.getter(#channel),
        ),
      ) as _i3.StreamController<List<int>>);
  @override
  set channel(_i3.StreamController<List<int>>? _channel) => super.noSuchMethod(
        Invocation.setter(
          #channel,
          _channel,
        ),
        returnValueForMissingStub: null,
      );
  @override
  bool get waitForToken => (super.noSuchMethod(
        Invocation.getter(#waitForToken),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  set waitForToken(bool? _waitForToken) => super.noSuchMethod(
        Invocation.setter(
          #waitForToken,
          _waitForToken,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i4.ObservableMap<_i2.CloudProviderId, String> get accounts =>
      (super.noSuchMethod(
        Invocation.getter(#accounts),
        returnValue: _FakeObservableMap_2<_i2.CloudProviderId, String>(
          this,
          Invocation.getter(#accounts),
        ),
        returnValueForMissingStub:
            _FakeObservableMap_2<_i2.CloudProviderId, String>(
          this,
          Invocation.getter(#accounts),
        ),
      ) as _i4.ObservableMap<_i2.CloudProviderId, String>);
  @override
  set accounts(_i4.ObservableMap<_i2.CloudProviderId, String>? _accounts) =>
      super.noSuchMethod(
        Invocation.setter(
          #accounts,
          _accounts,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i4.ReactiveContext get context => (super.noSuchMethod(
        Invocation.getter(#context),
        returnValue: _FakeReactiveContext_3(
          this,
          Invocation.getter(#context),
        ),
        returnValueForMissingStub: _FakeReactiveContext_3(
          this,
          Invocation.getter(#context),
        ),
      ) as _i4.ReactiveContext);
  @override
  _i3.Future<bool> initAccount(
    String? email,
    _i2.CloudProviderId? cloud,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #initAccount,
          [
            email,
            cloud,
          ],
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<void> updateInitAccounts(_i2.CloudProviderId? cloud) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateInitAccounts,
          [cloud],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  void resetChannel() => super.noSuchMethod(
        Invocation.method(
          #resetChannel,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
