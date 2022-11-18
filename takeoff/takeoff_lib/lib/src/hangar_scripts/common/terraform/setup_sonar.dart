// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/src/hangar_scripts/script.dart';

class SetUpSonar implements Script {
  String serviceAccountFile;
  String project;
  String terraformFilesPath;

  SetUpSonar({
    required this.serviceAccountFile,
    required this.project,
    required this.terraformFilesPath,
  });

  @override
  Map<int, String> get errors => {};

  @override
  List<String> toCommand() {
    List<String> args = [
      //TODO: Change this to the correct location
      "/scripts/sonarqube/gcloud/setup-terraform.sh",
      "--service_account_file",
      serviceAccountFile,
      "--project",
      project,
      "--terraform-files",
      terraformFilesPath
    ];

    return args;
  }
}
