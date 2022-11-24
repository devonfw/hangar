// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/src/hangar_scripts/script.dart';

class WayatSecrets implements Script {
  String projectName;
  String repoBack;
  String repoFront;
  String firebaseCredentialsFolder;

  WayatSecrets({
    required this.projectName,
    required this.repoBack,
    required this.repoFront,
    required this.firebaseCredentialsFolder,
  });

  @override
  Map<int, String> get errors => {};

  @override
  List<String> toCommand() {
    List<String> args = [
      "/accounts/gcloud/quickstart-wayat.sh",
      "-n",
      projectName,
      "-b",
      repoBack,
      "-f",
      repoFront,
      "-c",
      firebaseCredentialsFolder
    ];

    return args;
  }
}
