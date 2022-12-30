import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_gui/features/quickstart/controllers/quickstart_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

import 'quickstart_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MonitorController>(),
  MockSpec<TakeOffFacade>(),
])
void main() async {
  final MockTakeOffFacade mockTakeOffFacade = MockTakeOffFacade();
  final MockMonitorController mockMonitorController = MockMonitorController();
  late QuickstartController quickstartController;

  setUpAll(() async {
    GetIt.I.registerSingleton<MonitorController>(mockMonitorController);
    GetIt.I.registerSingleton<TakeOffFacade>(mockTakeOffFacade);
    quickstartController = QuickstartController();
  });

  ///createProject cannot be tested because of asynchronic behavior and that the internal functions should be tested instead
  // test('Test create Wayat google cloud', () async {
  //   await quickstartController.createWayat();
  //   verify(await mockTakeOffFacade.quickstartWayat(
  //     billingAccount: "1111-1111-1111-1111",
  //     googleCloudRegion: "europe-east1",
  //   ))
  //       .called(1);
  // });

  test('Form is valid', () async {
    bool result = quickstartController.isValidForm;
    expect(result, false);
  });

  test('Test reset form', () async {
    quickstartController.resetForm();

    expect(quickstartController.billingAccount, "");
    expect(quickstartController.region, "");
  });
}
