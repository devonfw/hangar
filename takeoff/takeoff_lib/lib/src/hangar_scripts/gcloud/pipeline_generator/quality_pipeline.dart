import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/pipeline_generator.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/common/machine_type.dart';

/// Script to create a Quality Pipeline in Google Cloud
class QualityPipelineGCloud extends PipelineGenerator {
  /// Build pipeline name.
  String buildPipelineName;

  /// Build pipeline name.
  String testPipelineName;

  /// SonarQube URL.
  String sonarUrl;

  /// SonarQube token.
  String sonarToken;

  /// Machine type for pipeline runner.
  MachineType? machineType;

  String? registryLocation;

  QualityPipelineGCloud(
      {required super.configFile,
      required super.pipelineName,
      required super.language,
      required super.localDirectory,
      required this.buildPipelineName,
      required this.testPipelineName,
      required this.sonarUrl,
      required this.sonarToken,
      super.targetBranch,
      super.languageVersion,
      this.machineType,
      this.registryLocation});

  @override
  List<String> toCommand() {
    List<String> args = super.toCommand();
    args.insert(0, "/scripts/pipelines/gcloud/pipeline_generator.sh");
    args.addAll([
      "--sonar-url",
      sonarUrl,
      "--sonar-token",
      sonarToken,
      "--build-pipeline-name",
      buildPipelineName,
      "--test-pipeline-name",
      testPipelineName
    ]);
    if (machineType != null) {
      args.addAll(["-m", machineType!.name]);
    }
    if (registryLocation != null) {
      args.addAll(["--registry-location", registryLocation!]);
    }
    return args;
  }
}
