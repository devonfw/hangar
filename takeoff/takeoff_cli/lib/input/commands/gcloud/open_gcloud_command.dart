import 'package:args/command_runner.dart';
import 'package:takeoff_cli/services/project_service.dart';
import 'package:takeoff_lib/takeoff_lib.dart';

class OpenGCloudCommand extends Command {
  final ProjectsService service;

  @override
  final String name = "web";

  final String resource = "--resource";

  @override
  final String description = "Open a project resources in web";

  OpenGCloudCommand(this.service) {
    argParser.addOption('web', mandatory: true);
    argParser.addOption('--resource',
        abbr: '-r',
        allowed: [
          Resource.ide.name,
          Resource.pipeline.name,
          Resource.feRepo.name,
          Resource.beRepo.name,
        ],
        help:
            "Chose resource type which needs to open: ide, pipeline, fe repo, be repo.");
  }

  @override
  void run() {
    service.openResource(
        projectId: argResults?["web"],
        cloudProviderId: CloudProviderId.gcloud,
        resource: Resource.fromString(argResults?["--resource"]));
  }
}
