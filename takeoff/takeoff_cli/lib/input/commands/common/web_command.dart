import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class WebCommand extends Command {
  final ProjectsService service;
  @override
  final String name = "web";
  @override
  final String description =
      "Open a web browser with the selected project resource";
  final CloudProviderId cloudProvider;

  WebCommand(this.service, this.cloudProvider) {
    argParser.addOption("project", mandatory: true);
    argParser.addOption("ide", mandatory: true);
    argParser.addOption("pipeline", mandatory: true);
    argParser.addOption("frontendrepo", mandatory: true);
    argParser.addOption("backendrepo", mandatory: true);
  }

  @override
  void run() {
    if (argResults?["ide"]) {
      service.openResource(
        projectId: argResults?["project"],
        cloudProviderId: cloudProvider,
        resourceType: ResourceType.ide,
      );
    } else if (argResults?["pipeline"]) {
      service.openResource(
        projectId: argResults?["project"],
        cloudProviderId: cloudProvider,
        resourceType: ResourceType.pipeline,
      );
    } else if (argResults?["frontendrepo"]) {
      service.openResource(
        projectId: argResults?["project"],
        cloudProviderId: cloudProvider,
        resourceType: ResourceType.frontend,
      );
    } else if (argResults?["backendrepo"]) {
      service.openResource(
        projectId: argResults?["project"],
        cloudProviderId: cloudProvider,
        resourceType: ResourceType.backend,
      );
    }
  }
}
