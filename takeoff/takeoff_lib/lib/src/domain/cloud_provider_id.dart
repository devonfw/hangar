/// Enum to distinguish between cloud providers
enum CloudProviderId {
  gcloud,
  aws,
  azure;

  factory CloudProviderId.fromString(String string) {
    switch (string) {
      case "gc":
        return gcloud;
      case "aws":
        return aws;
      case "azure":
        return azure;
      default:
        throw UnsupportedError(
            'Values for cloud provider can be "gc", "aws" or "azure"');
    }
  }
}
