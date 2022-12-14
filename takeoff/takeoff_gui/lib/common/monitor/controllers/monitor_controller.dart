import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:takeoff_gui/features/create/utils/create_message.dart';
import 'package:takeoff_gui/features/create/utils/type_message.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

part 'monitor_controller.g.dart';

// ignore: library_private_types_in_public_api
class MonitorController = _MonitorController with _$MonitorController;

abstract class _MonitorController with Store {
  StreamController<GuiMessage> outputChannel = StreamController.broadcast();
  StreamController<String> inputChannel = StreamController.broadcast();

  @observable
  ObservableList<CreateMessage> steps = ObservableList.of([]);

  @observable
  String projectUrl = "";

  @computed
  bool get hasFinished {
    List<TypeMessage> messages =
        steps.map((element) => element.typeMessage).toList();
    return messages.contains(TypeMessage.error) ||
        messages.contains(TypeMessage.success);
  }

  Future<void> monitorProcess(Function process) async {
    outputChannel.stream.listen((event) {
      if (event.type == MessageType.success) {
        projectUrl = event.url!;
      }
      steps.add(CreateMessage.fromGuiMessage(event));
    });
    try {
      await process();
    } catch (e) {
      steps.add(CreateMessage(TypeMessage.error, e.toString()));
    }
  }

  bool get isSuccess {
    List<TypeMessage> messages =
        steps.map((element) => element.typeMessage).toList();
    return messages.contains(TypeMessage.success);
  }

  void resetChannel() {
    outputChannel.close();
    inputChannel.close();
    inputChannel = StreamController.broadcast();
    outputChannel = StreamController.broadcast();
    steps = ObservableList.of([]);
  }
}
