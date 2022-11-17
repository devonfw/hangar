import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/language.dart';
import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/pipeline_generator.dart';

/// Script to create a Package Pipeline in Google Cloud
class PackagePipelineGCloud extends PipelineGenerator {
  /// Build pipeline name.
  String buildPipelineName;

  /// Quality pipeline name.
  String qualityPipelineName;

  /// Name (excluding tag) for the generated container image.
  String imageName;

  ///// Container registry login user.
  //String registryUser;

  ///// Container registry login password.
  //String registryPassword;

  /// Open the Pull Request on the web browser if it cannot be automatically merged. Requires [targetBranch].
  bool openPRinBrowser;

  /// [Required, if language not set] Path from the root of the project to its Dockerfile.
  /// Takes precedence over the language/framework default one.
  ///
  /// If this is preferred over [language], put the [language] value to `None`.
  String? dockerfile;

  PackagePipelineGCloud(
      {required super.configFile,
      required super.pipelineName,
      required super.language,
      required super.localDirectory,
      required this.buildPipelineName,
      required this.qualityPipelineName,
      required this.imageName,
      //required this.registryUser,
      //required this.registryPassword,
      this.openPRinBrowser = false,
      super.targetBranch,
      this.dockerfile});

  @override
  List<String> toCommand() {
    List<String> args = super.toCommand();
    args.insert(0, "/scripts/pipelines/gcloud/pipeline_generator.sh");
    args.addAll([
      "--build-pipeline-name",
      buildPipelineName,
      "--quality-pipeline-name",
      qualityPipelineName,
      "-i",
      imageName,
      //"-u",
      //registryUser,
      //"-p",
      //registryPassword
    ]);
    if (dockerfile != null && language == Language.none) {
      args.addAll(["--dockerfile", dockerfile!]);
    }
    if (openPRinBrowser && targetBranch != null) {
      args.add("-w");
    }
    return args;
  }
}
