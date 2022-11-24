import 'package:mobx/mobx.dart';
import 'package:takeoff_gui/features/quickstart/utils/apps.dart';

part 'quickstart_controller.g.dart';

// ignore: library_private_types_in_public_api
class QuickstartController = _QuickstartController with _$QuickstartController;

abstract class _QuickstartController with Store {
  @observable
  Apps app = Apps.wayat;

  @observable
  String billingAccount = "";

  @observable
  String region = "";

  @action
  void resetForm() {
    billingAccount = "";
    region = "";
  }

  @computed
  bool get isValidForm => billingAccount.isNotEmpty && region.isNotEmpty;
}
