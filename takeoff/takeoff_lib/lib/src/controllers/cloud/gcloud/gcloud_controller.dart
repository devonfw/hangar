import 'dart:async';

import 'package:takeoff_lib/src/controllers/cloud/gcloud/auth/gcloud_auth_controller.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/common/language/language.dart';

abstract class GoogleCloudController {
  Future<bool> createProject(
      {required String projectName,
      required String billingAccount,
      Language? backendLanguage,
      String? backendVersion,
      Language? frontendLanguage,
      String? frontendVersion,
      required String googleCloudRegion,
      StreamController<String>? infoStream});

  /// Logs in with Google Cloud.
  ///
  /// Receives the [email] to log in, an optional [GCloudAuthController] for
  /// testing purposes and a stdin stream for the GUI client to be able to write
  /// to the authentication process.
  Future<bool> init(String email,
      {bool useStdin = false,
      GCloudAuthController? controller,
      Stream<List<int>>? stdinStream});

  /// Runs the Google Cloud CLI with the specified project and service account
  Future<bool> run(String projectId);

  /// Returns the current logged Google Account or an empty String if there is none
  Future<String> getAccount(
      {GCloudAuthController? controller, Stream<List<int>>? stdinStream});

  /// Removes the current account from the TakeOff cache
  Future<bool> logOut(
      {GCloudAuthController? controller, Stream<List<int>>? stdinStream});

  /// Removes the project ID from the cache DB and the correspondent workspace folder
  Future<bool> cleanProject(String projectId);

  /// Creates and deploys wayat in Google Cloud
  Future<bool> wayatQuickstart(
      {required String billingAccount,
      required String googleCloudRegion,
      StreamController<String>? infoStream});
}
