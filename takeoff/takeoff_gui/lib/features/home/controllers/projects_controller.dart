import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

part 'projects_controller.g.dart';

// ignore: library_private_types_in_public_api
class ProjectsController = _ProjectsController with _$ProjectsController;

abstract class _ProjectsController with Store {
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();

  StreamController<List<int>> channel = StreamController();

  @observable
  bool waitForToken = false;

  @observable
  ObservableMap<CloudProviderId, String> accounts = ObservableMap.of({});

  @action
  Future<bool> initAccount(String email, CloudProviderId cloud) {
    late Future<bool> exitStatus;
    switch (cloud) {
      case CloudProviderId.gcloud:
        exitStatus = facade.init(email, CloudProviderId.gcloud,
            stdinStream: channel.stream);
        waitForToken = true;
        break;
      case CloudProviderId.aws:
        exitStatus = Future.value(false);
        Log.warning("Not implemented yet");
        break;
      case CloudProviderId.azure:
        exitStatus = Future.value(false);
        Log.warning("Not implemented yet");
        break;
    }
    return exitStatus;
  }

  @action
  void updateInitAccounts(CloudProviderId cloud) {
    facade.getCurrentAccount(cloud);

    // accounts = ObservableMap.of({});
  }

  void resetChannel() {
    waitForToken = false;
    channel.close();
    channel = StreamController();
  }
  /* rest of the class*/
}

// ignore: library_private_types_in_public_api
class FormLogin = _FormLogin with _$FormLogin;

abstract class _FormLogin with Store {
  String emailgc = "";

  @observable
  bool waitForToken = false;
}
