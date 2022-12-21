// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/wayat_script.dart';

class WayatBackend extends WayatScript {
  String projectName;
  String workspace;
  String backendRepoDir;
  String storageBucket;

  WayatBackend({
    required this.projectName,
    required this.workspace,
    required this.backendRepoDir,
    required this.storageBucket,
  });

  @override
  Map<int, String> get errors => {};

  @override
  List<String> toCommand() {
    List<String> args = [
      "/scripts/quickstart/gcloud/quickstart-wayat-backend.sh",
      "-p",
      projectName,
      "-w",
      workspace,
      "-d",
      backendRepoDir,
      "--storage-bucket",
      storageBucket,
    ];

    return args;
  }
}
