import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

part 'projects_controller.g.dart';

// ignore: library_private_types_in_public_api
class ProjectsController = _ProjectsController with _$ProjectsController;

abstract class _ProjectsController with Store {
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();

  String emailgc = "";

  StreamController channel = StreamController();

  @observable
  ObservableFuture<bool>? exitCode;

  @observable
  bool waitForToken = false;

  @observable
  ObservableMap<String, String> accounts = ObservableMap.of({});

  @action
  void initAccount(String cloud) {
    channel.stream.listen((event) {
      print(event);
    });
    switch (cloud) {
      case "gc":
        exitCode = ObservableFuture(facade.initGoogleCloud(emailgc));
        waitForToken = true;
        break;
      case "aws":
        Log.warning("Not implemented yet");
        break;
      case "azure":
        Log.warning("Not implemented yet");
        break;
    }
    updateInitAccounts();
  }

  @action
  void updateInitAccounts() {
    accounts = ObservableMap.of({"gc": "test@mail.com"});
  }
  /* rest of the class*/
}

class FormLogin = _FormLogin with _$FormLogin;

abstract class _FormLogin with Store {
  String emailgc = "";

  @observable
  bool waitForToken = false;
}
