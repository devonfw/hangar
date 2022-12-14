import 'package:takeoff_lib/src/domain/language.dart';
import 'package:test/test.dart';

void main() {
  test("Language quarkus returns the correct language type", () {
    Language language = Language.fromString('quarkus');
    expect(language, Language.quarkus);
  });

  test("Language quarkus-jvm returns the correct language type", () {
    Language language = Language.fromString('quarkus-jvm');
    expect(language, Language.quarkusJVM);
  });

  test("Language node returns the correct language type", () {
    Language language = Language.fromString('node');
    expect(language, Language.node);
  });

  test("Language angular returns the correct language type", () {
    Language language = Language.fromString('angular');
    expect(language, Language.angular);
  });

  test("Language python returns the correct language type", () {
    Language language = Language.fromString('python');
    expect(language, Language.python);
  });

  test("Language flutter returns the correct language type", () {
    Language language = Language.fromString('flutter');
    expect(language, Language.flutter);
  });

  test("Language empty returns the correct language type", () {
    Language language = Language.fromString('');
    expect(language, Language.none);
  });

  test("Language unknown returns the correct language type", () {
    Language language = Language.fromString('unknown');
    expect(language, Language.none);
  });
}
