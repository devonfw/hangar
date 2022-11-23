import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/pipeline_generator.dart';
import 'package:takeoff_lib/src/hangar_scripts/gcloud/common/machine_type.dart';

/// Script to create a Test Pipeline in Google Cloud
class TestPipelineGCloud extends PipelineGenerator {
  /// Build pipeline name.
  String buildPipelineName;

  /// Machine type for pipeline runner.
  MachineType? machineType;

  /// Path to be persisted as an artifact after pipeline execution,
  /// e.g. where the application stores logs or any other blob on runtime.
  String? artifactPath;

  String? registryLocation;

  TestPipelineGCloud(
      {required super.configFile,
      required super.pipelineName,
      required super.language,
      required super.localDirectory,
      required this.buildPipelineName,
      super.targetBranch,
      super.languageVersion,
      this.machineType,
      this.registryLocation,
      this.artifactPath});

  @override
  List<String> toCommand() {
    List<String> args = super.toCommand();
    args.insert(0, "/scripts/pipelines/gcloud/pipeline_generator.sh");
    args.addAll(["--build-pipeline-name", buildPipelineName]);
    if (machineType != null) {
      args.addAll(["-m", machineType!.name]);
    }
    if (artifactPath != null) {
      args.addAll(["-a", artifactPath!]);
    }
    if (languageVersion != null) {
      args.addAll(["--language-version", languageVersion!]);
    }
    if (registryLocation != null) {
      args.addAll(["--registry-location", registryLocation!]);
    }
    return args;
  }
}
