import 'package:takeoff_lib/src/hangar_scripts/common/pipeline_generator/language.dart';
import 'package:takeoff_lib/src/hangar_scripts/script.dart';

/// Base class with common arguments for the generate pipeline scripts.
abstract class PipelineGenerator implements Script {
  /// Configuration file containing pipeline definition.
  String configFile;

  /// Name that will be set to the pipeline.
  String pipelineName;

  /// Language or framework of the project.
  Language language;

  /// Local directory of your project.
  String localDirectory;

  /// Name of the branch to which the Pull Request will target. PR is not created if the flag is not provided.
  String? targetBranch;

  /// [Required, if Flutter or Python] Language or framework version.
  String? languageVersion;

  PipelineGenerator({
    required this.configFile,
    required this.pipelineName,
    required this.language,
    required this.localDirectory,
    this.targetBranch,
    this.languageVersion,
  });

  @override
  Map<int, String> get errors => {
        2: "The arguments are not correct",
        127:
            "Some necessary package is not installed:\nThe requisites are:\nGit, Github CLI, Azure CLI, GCloud CLI and Python"
      };

  @override
  List<String> toCommand() {
    List<String> args = [
      "-c",
      configFile,
      "-n",
      pipelineName,
      "-d",
      localDirectory
    ];
    if (language != Language.none) {
      args.addAll(["-l", language.name]);
    }
    if (targetBranch != null) {
      args.addAll(["-b", targetBranch!]);
    }
    if (languageVersion != null) {
      args.addAll(["--language-version", languageVersion!]);
    }

    return args;
  }
}
