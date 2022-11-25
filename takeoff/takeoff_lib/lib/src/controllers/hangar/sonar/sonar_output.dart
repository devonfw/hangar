// ignore_for_file: public_member_api_docs, sort_constructors_first
class SonarOutput {
  String token;
  String url;

  SonarOutput({
    required this.token,
    required this.url,
  });

  factory SonarOutput.fromMap(Map<String, dynamic> map) {
    return SonarOutput(
        token: map["sonarqube_token"]["value"],
        url: map["sonarqube_url"]["value"]);
  }
}
