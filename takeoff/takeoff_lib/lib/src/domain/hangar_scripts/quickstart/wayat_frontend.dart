// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/src/domain/hangar_scripts/quickstart/wayat_script.dart';

class WayatFrontend extends WayatScript {
  String projectName;
  String workspace;
  String frontendRepoDir;
  String keystoreFile;
  String backendUrl;
  String frontendUrl;
  String mapsStaticSecret;

  WayatFrontend({
    required this.projectName,
    required this.workspace,
    required this.frontendRepoDir,
    required this.keystoreFile,
    required this.backendUrl,
    required this.frontendUrl,
    required this.mapsStaticSecret,
  });

  @override
  Map<int, String> get errors => {};

  @override
  List<String> toCommand() {
    List<String> args = [
      "/scripts/quickstart/gcloud/quickstart-wayat-frontend.sh",
      "-p",
      projectName,
      "-w",
      workspace,
      "-d",
      frontendRepoDir,
      "--keystore",
      keystoreFile,
      "--backend-url",
      backendUrl,
      "--frontend-url",
      frontendUrl,
      "--maps-static-secret",
      mapsStaticSecret,
    ];

    return args;
  }
}
