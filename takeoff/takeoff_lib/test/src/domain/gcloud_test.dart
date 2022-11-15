import 'package:takeoff_lib/src/domain/gcloud.dart';
import 'package:test/test.dart';

void main() {
  test("GCloud entity getters are correct", () {
    GCloud gCloud = GCloud();
    expect(gCloud.hostFolderName, "gcloud");
    expect(gCloud.name, "Google Cloud");
  });
}
