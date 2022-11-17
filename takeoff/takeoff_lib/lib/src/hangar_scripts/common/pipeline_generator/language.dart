/// Possible values for the parameter [language] of [PipelineGenerator]
enum Language {
  quarkus("quarkus"),
  quarkusJVM("quarkus-jvm"),
  node("node"),
  angular("angular"),
  python("python"),
  flutter("flutter"),
  none("");

  final String name;
  const Language(this.name);
}
