// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/src/hangar_scripts/script.dart';

class InitCloudRun implements Script {
  String project;
  String name;
  String? region;
  String? urlOutputFile;

  InitCloudRun({
    required this.project,
    required this.name,
    this.region,
    this.urlOutputFile,
  });

  @override
  Map<int, String> get errors => {};

  @override
  List<String> toCommand() {
    List<String> args = [
      "/scripts/quickstart/gcloud/init-cloud-run.sh",
      "-p",
      project,
      "-n",
      name
    ];

    if (region != null) {
      args.addAll(["-r", region!]);
    }

    if (urlOutputFile != null) {
      args.addAll(["-o", urlOutputFile!]);
    }

    return args;
  }
}
