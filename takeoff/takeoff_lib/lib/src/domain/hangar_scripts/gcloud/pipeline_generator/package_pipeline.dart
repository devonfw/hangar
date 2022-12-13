import 'package:takeoff_lib/src/domain/language.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/common/pipeline_generator/pipeline_generator.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/pipeline_generator/flutter_web_renderer.dart';

/// Script to create a Package Pipeline in Google Cloud
class PackagePipelineGCloud extends PipelineGenerator {
  /// Build pipeline name.
  String buildPipelineName;

  /// Quality pipeline name.
  String qualityPipelineName;

  /// Name (excluding tag) for the generated container image.
  String imageName;

  /// Open the Pull Request on the web browser if it cannot be automatically merged. Requires [targetBranch].
  bool openPRinBrowser;

  bool? androidFlutterPlatform;
  bool? webFlutterPlatform;

  FlutterWebRenderer? flutterWebRenderer;

  /// [Required, if language not set] Path from the root of the project to its Dockerfile.
  /// Takes precedence over the language/framework default one.
  ///
  /// If this is preferred over [language], put the [language] value to `None`.
  String? dockerfile;

  String? registryLocation;

  PackagePipelineGCloud(
      {required super.configFile,
      required super.pipelineName,
      required super.language,
      required super.localDirectory,
      required this.buildPipelineName,
      required this.qualityPipelineName,
      required this.imageName,
      super.languageVersion,
      this.openPRinBrowser = false,
      super.targetBranch,
      this.registryLocation,
      this.dockerfile,
      this.androidFlutterPlatform,
      this.webFlutterPlatform,
      this.flutterWebRenderer});

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
    if (languageVersion != null) {
      args.addAll(["--language-version", languageVersion!]);
    }
    if (dockerfile != null && language == Language.none) {
      args.addAll(["--dockerfile", dockerfile!]);
    }
    if (openPRinBrowser && targetBranch != null) {
      args.add("-w");
    }
    if (registryLocation != null) {
      args.addAll(["--registry-location", registryLocation!]);
    }
    if (androidFlutterPlatform != null) {
      args.add("--flutter-android-platform");
    }
    if (webFlutterPlatform != null) {
      args.add("--flutter-web-platform");
    }
    if (flutterWebRenderer != null) {
      args.addAll(["--flutter-web-renderer", flutterWebRenderer!.name]);
    }

    return args;
  }
}
