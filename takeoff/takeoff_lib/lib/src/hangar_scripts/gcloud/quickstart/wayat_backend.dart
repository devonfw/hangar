// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/src/hangar_scripts/script.dart';

class WayatBackend implements Script {
  String workspace;
  String backendRepoDir;
  String storageBucket;

  WayatBackend({
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
