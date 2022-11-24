// Mocks generated by Mockito 5.3.2 from annotations
// in takeoff_gui/test/features/home/controllers/projects_controller_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:takeoff_lib/src/domain/cloud_provider_id.dart' as _i4;
import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/language.dart'
    as _i5;
import 'package:takeoff_lib/src/takeoff_facade.dart' as _i2;

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

/// A class which mocks [TakeOffFacade].
///
/// See the documentation for Mockito's code generation for more information.
class MockTakeOffFacade extends _i1.Mock implements _i2.TakeOffFacade {
  @override
  _i3.Future<bool> initialize() => (super.noSuchMethod(
        Invocation.method(
          #initialize,
          [],
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<String> getCurrentAccount(_i4.CloudProviderId? cloudProvider) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCurrentAccount,
          [cloudProvider],
        ),
        returnValue: _i3.Future<String>.value(''),
        returnValueForMissingStub: _i3.Future<String>.value(''),
      ) as _i3.Future<String>);
  @override
  _i3.Future<bool> init(
    String? email,
    _i4.CloudProviderId? cloudProvider, {
    _i3.Stream<List<int>>? stdinStream,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #init,
          [
            email,
            cloudProvider,
          ],
          {#stdinStream: stdinStream},
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<bool> logOut(
    _i4.CloudProviderId? cloudProvider, {
    _i3.Stream<List<int>>? stdinStream,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #logOut,
          [cloudProvider],
          {#stdinStream: stdinStream},
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<bool> createProjectGCloud({
    required String? projectName,
    required String? billingAccount,
    required _i5.Language? backendLanguage,
    String? backendVersion,
    required _i5.Language? frontendLanguage,
    String? frontendVersion,
    required String? googleCloudRegion,
    _i3.StreamController<String>? infoStream,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #createProjectGCloud,
          [],
          {
            #projectName: projectName,
            #billingAccount: billingAccount,
            #backendLanguage: backendLanguage,
            #backendVersion: backendVersion,
            #frontendLanguage: frontendLanguage,
            #frontendVersion: frontendVersion,
            #googleCloudRegion: googleCloudRegion,
            #infoStream: infoStream,
          },
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<bool> quickstartWayat({
    required String? billingAccount,
    required String? googleCloudRegion,
    _i3.StreamController<String>? infoStream,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #quickstartWayat,
          [],
          {
            #billingAccount: billingAccount,
            #googleCloudRegion: googleCloudRegion,
            #infoStream: infoStream,
          },
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<bool> cleanProject(
    _i4.CloudProviderId? cloudProvider,
    String? projectId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #cleanProject,
          [
            cloudProvider,
            projectId,
          ],
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<List<String>> getProjects(_i4.CloudProviderId? cloudProvider) =>
      (super.noSuchMethod(
        Invocation.method(
          #getProjects,
          [cloudProvider],
        ),
        returnValue: _i3.Future<List<String>>.value(<String>[]),
        returnValueForMissingStub: _i3.Future<List<String>>.value(<String>[]),
      ) as _i3.Future<List<String>>);
}
