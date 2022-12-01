import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:takeoff_gui/common/monitor/controllers/monitor_controller.dart';
import 'package:takeoff_gui/features/quickstart/utils/apps.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

part 'quickstart_controller.g.dart';

// ignore: library_private_types_in_public_api
class QuickstartController = _QuickstartController with _$QuickstartController;

abstract class _QuickstartController with Store {
  final TakeOffFacade facade = GetIt.I.get<TakeOffFacade>();

  final MonitorController monitorController = GetIt.I.get<MonitorController>();

  @observable
  Apps app = Apps.wayat;

  @observable
  String billingAccount = "";

  @observable
  String region = "";

  @computed
  bool get isValidForm => billingAccount.isNotEmpty && region.isNotEmpty;

  void createWayat() {
    monitorController.monitorProcess(() async => await facade.quickstartWayat(
        billingAccount: billingAccount,
        googleCloudRegion: region,
        infoStream: monitorController.outputChannel));
  }

  @action
  void resetForm() {
    billingAccount = "";
    region = "";
  }
}
