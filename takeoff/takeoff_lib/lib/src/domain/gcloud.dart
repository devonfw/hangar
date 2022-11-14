import 'package:takeoff_lib/src/domain/cloud_provider.dart';

/// Specific implementation of Google Cloud as a Cloud Provider.
///
/// This class exists currently to generify implementations, like `AuthController<T>`
class GCloud extends CloudProvider {
  @override
  String get hostFolderName => "gcloud";
  @override
  String get name => "Google Cloud";
}
