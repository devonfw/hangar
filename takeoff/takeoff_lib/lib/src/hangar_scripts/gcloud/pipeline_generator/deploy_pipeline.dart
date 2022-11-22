import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/pipeline_generator.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/common/machine_type.dart';

/// Script to create a deployment pipeline to Cloud Run in Google Cloud
class DeployPipelineGCloud extends PipelineGenerator {
  /// Name for the cloud run service.
  String serviceName;

  /// Region where the service will be deployed.
  String gCloudRegion;

  /// Listening port of the service. If no value is passed is 8080.
  int? port;

  /// Machine type for pipeline runner.
  MachineType? machineType;

  DeployPipelineGCloud(
      {required super.configFile,
      required super.pipelineName,
      required super.language,
      required super.localDirectory,
      required this.serviceName,
      required this.gCloudRegion,
      super.targetBranch,
      super.languageVersion,
      this.port,
      this.machineType});

  @override
  List<String> toCommand() {
    List<String> args = super.toCommand();
    args.insert(0, "/scripts/pipelines/gcloud/pipeline_generator.sh");
    args.addAll(
        ["--service-name", serviceName, "--gcloud-region", gCloudRegion]);
    if (languageVersion != null) {
      args.addAll(["--language-version", languageVersion!]);
    }
    if (port != null) {
      args.addAll(["--port", port.toString()]);
    }
    if (machineType != null) {
      args.addAll(["-m", machineType!.name]);
    }
    return args;
  }
}
