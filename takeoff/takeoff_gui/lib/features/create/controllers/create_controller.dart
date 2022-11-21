import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

part 'create_controller.g.dart';

// ignore: library_private_types_in_public_api
class CreateController = _CreateController with _$CreateController;

abstract class _CreateController with Store {
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();

  @observable
  String cloudProvider = "";

  @observable
  String repoProvider = "";

  @observable
  String projectName = "";

  @observable
  String billingAccount = "";

  @observable
  String frontendLanguage = "Flutter";

  @observable
  String frontendVersion = "v10";

  @observable
  String backendLanguage = "Python";

  @observable
  String backendVersion = "v10";
}
