import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

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

  test('Test monitor process', () async {
    GuiMessage event = GuiMessage(
        type: MessageType.success,
        message: "Test GuiMessage - Seccess",
        url: "Test url");
    await monitorController
        .monitorProcess(() => {monitorController.projectUrl = "Test url"});
    expect(monitorController.projectUrl, event.url);

    event =
        GuiMessage(type: MessageType.error, message: "Test GuiMessage - Error");
    await monitorController
        .monitorProcess(() => {monitorController.projectUrl = ""});
    expect(monitorController.projectUrl, "");
  });

  test('Test reset channel', () async {
    GuiMessage event = GuiMessage(
        type: MessageType.success,
        message: "Test GuiMessage - outputChannel stream");
    String message = "Test inputChannel stream value";

    monitorController.inputChannel.add("Test inputChannel stream value");
    monitorController.outputChannel.add(event);

    bool result = monitorController.inputChannel.stream.take(1) == message;
    expect(result, false);

    result = monitorController.outputChannel.stream.take(1) == event;
    expect(result, false);

    monitorController.resetChannel();

    result = monitorController.outputChannel.stream.take(1).isBroadcast;
    expect(result, true);
  });
}
