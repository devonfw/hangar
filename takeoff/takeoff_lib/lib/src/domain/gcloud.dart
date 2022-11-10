import 'package:takeoff_lib/src/domain/cloud_provider.dart';
import 'package:takeoff_lib/src/domain/cloud_provider_enum.dart';

class GCloud extends CloudProvider {
  @override
  String get hostFolderName => "gcloud";
  @override
  String get name => "Google Cloud";
}
