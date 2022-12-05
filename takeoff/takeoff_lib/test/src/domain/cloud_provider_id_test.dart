import 'package:takeoff_lib/src/domain/cloud_provider_id.dart';
import 'package:test/test.dart';

void main() {
  test("CloudProviderId entity for 'gc' returns gcloud id", () {
    CloudProviderId cloudProviderId = CloudProviderId.fromString('gc');
    expect(cloudProviderId, CloudProviderId.gcloud);
  });

  test("CloudProviderId entity for 'aws' returns aws id", () {
    CloudProviderId cloudProviderId = CloudProviderId.fromString('aws');
    expect(cloudProviderId, CloudProviderId.aws);
  });

  test("CloudProviderId entity for 'azure' returns azure id", () {
    CloudProviderId cloudProviderId = CloudProviderId.fromString('azure');
    expect(cloudProviderId, CloudProviderId.azure);
  });

  // test("CloudProviderId entity for '' returns unsuported error", () {
  //   CloudProviderId cloudProviderId = CloudProviderId.fromString('');
  //   expect(cloudProviderId, isUnsupportedError);
  // });

}
