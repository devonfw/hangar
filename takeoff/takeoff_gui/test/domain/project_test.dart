import 'package:flutter_test/flutter_test.dart';
import 'package:takeoff_gui/domain/project.dart';

// @GenerateMocks([])
void main() async {
  setUpAll(() async {});

  test('Check project constructor and name', () async {
    String name = "Project Name";
    Project project = Project(name: name);
    expect(project.name, name);
  });
}
