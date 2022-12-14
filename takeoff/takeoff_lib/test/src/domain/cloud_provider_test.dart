import 'package:takeoff_lib/src/domain/cloud_provider.dart';
import 'package:takeoff_lib/src/domain/cloud_provider_id.dart';
import 'package:takeoff_lib/src/domain/gcloud.dart';
import 'package:test/test.dart';

void main() {
  test("CloudProvider entity for gcloud returns a gcloud instance", () {
    CloudProvider cloudProvider = CloudProvider.fromId(CloudProviderId.gcloud);
    expect(cloudProvider, isA<GCloud>());
  });

  // test("CloudProvider entity for aws returns not supported error", () {
  //   CloudProvider cloudProvider = CloudProvider.fromId(CloudProviderId.aws);
  //   expect(cloudProvider, isUnsupportedError);
  // });

  // test("CloudProvider entity for azure returns not supported error", () {
  //   expect(CloudProvider.fromId(CloudProviderId.azure), isUnsupportedError);
  // });

}
