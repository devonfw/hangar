// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/src/domain/hangar_scripts/script.dart';

class SetUpFirebase implements Script {
  String projectName;
  String credentialsOutputFolder;
  String? firestoreRegion;
  bool? enableMaps;
  bool? setUpIOS;
  bool? setUpAndroid;
  bool? setUpWeb;

  SetUpFirebase({
    required this.projectName,
    required this.credentialsOutputFolder,
    this.firestoreRegion,
    this.enableMaps,
    this.setUpIOS,
    this.setUpAndroid,
    this.setUpWeb,
  });

  @override
  Map<int, String> get errors => {};

  @override
  List<String> toCommand() {
    List<String> args = [
      "/scripts/accounts/gcloud/setup-firebase.sh",
      "-n",
      projectName,
      "-o",
      credentialsOutputFolder
    ];
    if (firestoreRegion != null) {
      args.addAll(["-r", firestoreRegion!]);
    }
    if (enableMaps != null) {
      args.add("--enable-maps");
    }
    if (setUpIOS != null) {
      args.add("--setup-ios");
    }
    if (setUpAndroid != null) {
      args.add("--setup-android");
    }
    if (setUpWeb != null) {
      args.add("--setup-web");
    }

    return args;
  }
}
