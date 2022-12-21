import 'package:takeoff_lib/src/domain/cloud_provider_id.dart';
import 'package:takeoff_lib/src/domain/gcloud.dart';

/// Defines all the necessary fields to identify a Cloud Provider
abstract class CloudProvider {
  CloudProvider();

  String get hostFolderName;
  String get name;

  factory CloudProvider.fromId(CloudProviderId id) {
    switch (id) {
      case CloudProviderId.gcloud:
        return GCloud();
      case CloudProviderId.aws:
        throw UnsupportedError("Cloud provider AWS currently not supported");
      case CloudProviderId.azure:
        throw UnsupportedError("Cloud provider Azure currently not supported");
    }
  }
}
