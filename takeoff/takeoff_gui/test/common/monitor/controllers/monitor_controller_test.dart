import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';

//@GenerateNiceMocks([])
void main() async {
  late MonitorController monitorController;

  setUpAll(() async {
    monitorController = MonitorController();
  });

  test('Test monitor hasFinished', () async {
    bool result = monitorController.hasFinished;
    expect(result, false);
  });
  test('Test monitor isSuccess', () async {
    bool result = monitorController.isSuccess;
    expect(result, false);
  });
}
