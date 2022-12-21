import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/domain/project.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

// @GenerateMocks([])
void main() async {
  setUpAll(() async {});

  test('Check project constructor and name', () async {
    String name = "Project Name";
    Project project = Project(name: name, cloud: CloudProviderId.gcloud);
    expect(project.name, name);
  });
}
