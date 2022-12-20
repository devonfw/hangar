import 'package:takeoff_lib/src/domain/hangar_scripts/common/pipeline_generator/pipeline_generator.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/common/machine_type.dart';

/// Script to create a Build Pipeline in Google Cloud
class BuildPipelineGCloud extends PipelineGenerator {
  /// [Required, if Flutter] Artifact registry location.
  String? registryLocation;

  /// Target directory of build process. Takes precedence over the language/framework default one.
  String? targetDirectory;

  ///  Machine type for pipeline runner.
  MachineType? machineType;

  BuildPipelineGCloud(
      {required super.configFile,
      required super.pipelineName,
      required super.language,
      required super.localDirectory,
      super.targetBranch,
      super.languageVersion,
      this.registryLocation,
      this.targetDirectory,
      this.machineType});

  @override
  List<String> toCommand() {
    List<String> args = super.toCommand();
    args.insert(0, "/scripts/pipelines/gcloud/pipeline_generator.sh");
    if (registryLocation != null) {
      args.addAll(["--registry-location", registryLocation!]);
    }
    if (targetDirectory != null) {
      args.addAll(["-t", targetDirectory!]);
    }
    if (machineType != null) {
      args.addAll(["-m", machineType!.name]);
    }
    return args;
  }
}
