enum GCloudResourceUrl {
  baseConsolePath("https://console.cloud.google.com"),
  baseSourcePath("https://source.cloud.google.com");

  const GCloudResourceUrl(this.rawValue);
  final String rawValue;
}
