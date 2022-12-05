import 'package:takeoff_lib/src/domain/sonar_output.dart';
import 'package:test/test.dart';

void main() {
  test("Sonar output entity getters are correct", () {
    SonarOutput sonarOutput = SonarOutput(token: 'token', url: 'url');
    expect(sonarOutput.token, "token");
    expect(sonarOutput.url, "url");
  });

  test('Sonar output from map get the correct values', () {
    final Map<String,dynamic> mapSonarOutput = {'sonarqube_token':{'value':'token'},'sonarqube_url':{'value':'url'}};

    SonarOutput sonarOutput = SonarOutput.fromMap(mapSonarOutput);
    expect(sonarOutput.token, "token");
    expect(sonarOutput.url, "url");
  });

}
