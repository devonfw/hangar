import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_gui/features/home/controllers/projects_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';
import './projects_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<TakeOffFacade>()])
void main() async {
  late ProjectsController controller;
  MockTakeOffFacade facade = MockTakeOffFacade();
  setUpAll(() async {
    GetIt.I.registerSingleton<TakeOffFacade>(facade);
    controller = ProjectsController();
  });

  test('Test initAccount google cloud', () async {
    String testEmail = "test@mail.com";
    CloudProviderId cloud = CloudProviderId.gcloud;
    controller.initAccount(testEmail, cloud);
    verify(facade.init(testEmail, cloud, stdinStream: anyNamed("stdinStream")))
        .called(1);
    expect(controller.waitForToken, true);
  });

  test('Test initAccount AWS', () async {
    String testEmail = "test@mail.com";
    CloudProviderId cloud = CloudProviderId.aws;
    when(facade.init(testEmail, cloud))
        .thenAnswer((realInvocation) => Future.value(false));
    bool result = await controller.initAccount(testEmail, cloud);
    expect(result, false);
  });

  test('Test initAccount Azure', () async {
    String testEmail = "test@mail.com";
    CloudProviderId cloud = CloudProviderId.azure;
    when(facade.init(testEmail, cloud))
        .thenAnswer((realInvocation) => Future.value(false));
    bool result = await controller.initAccount(testEmail, cloud);
    expect(result, false);
  });

  test('Test updateInitAccounts', () async {
    CloudProviderId cloud = CloudProviderId.gcloud;
    String account = "test@mail.com";
    when(facade.getCurrentAccount(cloud))
        .thenAnswer((realInvocation) => Future.value("test@mail.com"));
    await controller.updateInitAccounts();
    expect(controller.accounts[cloud], account);
  });

  test('Test resetChannel', () async {
    controller.waitForToken = true;
    StreamController oldChannel = StreamController();
    controller.resetChannel();
    expect(controller.waitForToken, false);
    expect(oldChannel != controller.channel, true);
  });

  test('Test logOut', () async {
    await controller.logOut(CloudProviderId.aws);
    verify(facade.getCurrentAccount(any)).called(greaterThan(0));

    await controller.logOut(CloudProviderId.azure);
    verify(facade.getCurrentAccount(any)).called(greaterThan(0));

    await controller.logOut(CloudProviderId.gcloud);
    verify(facade.logOut(CloudProviderId.gcloud)).called(1);
    verify(facade.getCurrentAccount(any)).called(greaterThan(0));
  });
}
