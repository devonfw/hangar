enum Resource {
  ide("ide"),
  pipeline("pipeline"),
  feRepo("fe repo"),
  beRepo("be repo"),
  none("");

  final String name;
  const Resource(this.name);

  factory Resource.fromString(String string) {
    return Resource.values.firstWhere((element) => element.name == string,
        orElse: () => Resource.none);
  }

  @override
  String toString() => name;
}
