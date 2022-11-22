import 'package:takeoff_gui/features/create/utils/provider_ci_cd.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class CloudProvidersComb {
  static Map<CloudProviderId, List<ProviderCICD>> versionsLanguages = {
    CloudProviderId.gcloud: [
      ProviderCICD.gcloud,
      ProviderCICD.azureDevOps,
      ProviderCICD.github
    ],
    CloudProviderId.azure: [ProviderCICD.azureDevOps, ProviderCICD.github],
    CloudProviderId.aws: [ProviderCICD.azureDevOps, ProviderCICD.github],
  };
}
