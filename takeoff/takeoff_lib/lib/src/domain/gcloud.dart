import 'package:takeoff_lib/src/domain/cloud_provider.dart';

/// Specific implementation of Google Cloud as a Cloud Provider
class GCloud extends CloudProvider {
  @override
  String get hostFolderName => "gcloud";
  @override
  String get name => "Google Cloud";
}
