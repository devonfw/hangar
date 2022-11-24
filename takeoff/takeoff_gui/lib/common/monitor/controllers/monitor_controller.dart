import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:takeoff_gui/features/create/utils/create_message.dart';
import 'package:takeoff_gui/features/create/utils/type_message.dart';

part 'monitor_controller.g.dart';

// ignore: library_private_types_in_public_api
class MonitorController = _MonitorController with _$MonitorController;

abstract class _MonitorController with Store {
  StreamController<String> channel = StreamController();

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

  void monitorProcess(Function process) {
    channel.stream.listen((event) {
      if (event.contains("http")) {
        projectUrl = event;
        steps.add(
            CreateMessage(TypeMessage.success, "Project created succesfully"));
      } else {
        steps.add(CreateMessage(TypeMessage.info, event));
      }
    });
    try {
      process();
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
    channel.close();
    channel = StreamController();
    steps = ObservableList.of([]);
  }
}
