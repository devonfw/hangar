// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/src/domain/hangar_scripts/script.dart';

class SetUpSonar implements Script {
  String serviceAccountFile;
  String project;
  String stateFolder;

  SetUpSonar({
    required this.serviceAccountFile,
    required this.project,
    required this.stateFolder,
  });

  @override
  Map<int, String> get errors => {};

  @override
  List<String> toCommand() {
    List<String> args = [
      "/scripts/sonarqube/gcloud/sonarqube.sh",
      "apply",
      "--state-folder",
      stateFolder,
      "--service_account_file",
      serviceAccountFile,
      "--project",
      project,
    ];

    return args;
  }
}
