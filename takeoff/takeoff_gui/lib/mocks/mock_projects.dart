import 'package:takeoff_gui/domain/project.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class MockProjects {
  static List<Project> projectsAWS = [
    Project(name: "AWS Fake1", cloud: CloudProviderId.aws),
    Project(name: "AWS Fake2", cloud: CloudProviderId.aws),
    Project(name: "AWS Fake3", cloud: CloudProviderId.aws),
    Project(name: "AWS Fake4", cloud: CloudProviderId.aws),
    Project(name: "AWS Fake5", cloud: CloudProviderId.aws),
  ];

  static List<Project> projectsGCloud = [
    Project(name: "GCloud Fake1", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake2", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake3", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake4", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake5", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake6", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake7", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake8", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake9", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake10", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake11", cloud: CloudProviderId.gcloud),
    Project(name: "GCloud Fake12", cloud: CloudProviderId.gcloud),
  ];

  static List<Project> projectsAzure = [
    Project(name: "Azure Fake1", cloud: CloudProviderId.azure),
    Project(name: "Azure Fake2", cloud: CloudProviderId.azure),
    Project(name: "Azure Fake3", cloud: CloudProviderId.azure),
    Project(name: "Azure Fake4", cloud: CloudProviderId.azure),
    Project(name: "Azure Fake5", cloud: CloudProviderId.azure),
    Project(name: "Azure Fake6", cloud: CloudProviderId.azure),
    Project(name: "Azure Fake7", cloud: CloudProviderId.azure),
    Project(name: "Azure Fake8", cloud: CloudProviderId.azure),
  ];
}
