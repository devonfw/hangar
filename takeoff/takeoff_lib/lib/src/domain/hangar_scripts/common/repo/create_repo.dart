import 'package:takeoff_lib/src/domain/hangar_scripts/common/repo/branch_strategy.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/common/repo/repo_action.dart';
import 'package:takeoff_lib/src/domain/hangar_scripts/script.dart';

/// Creates or imports a repository on a provider
///
/// It allows you to, based on the action, either:
///
/// Create an empty repository with just a README file and clone it to your computer
/// into the directory you set. Useful when starting a project from scratch.
///
/// Import an already existing directory or Git repository into your project giving
/// a path or an URL. Useful for taking to a provider the development of an existing project
abstract class CreateRepo implements Script {
  /// Use case to fulfil: create, import.
  RepoAction action;

  /// Path to the directory where your repository will be cloned or initialized.
  String directory;

  /// Name for the repository. By default, the source repository or
  /// directory name (either new or existing, depending on use case) is used.
  String? name;

  /// Source URL of the Git repository to import.
  String? sourceGitUrl;

  /// Source branch to be used as a basis to initialize the repository on import, as master branch.
  String? sourceBranch;

  /// Removes branches other than the (possibly new) default one.
  bool? removeOtherBranches;

  /// Creates branches and policies required for the desired workflow. Requires [sourceBranch] on import.
  BranchStrategy? setUpBranchStrategy;

  /// Skips any user confirmation.
  bool? force;

  /// When combined with [sourceGitURl] and [removeOtherBranches], imports only
  /// the specified subpath of the source Git repository.
  String? subpath;

  CreateRepo({
    required this.action,
    required this.directory,
    this.name,
    this.sourceGitUrl,
    this.sourceBranch,
    this.removeOtherBranches,
    this.setUpBranchStrategy,
    this.force,
    this.subpath,
  });

  @override
  Map<int, String> get errors =>
      {1: "Unexpected error. Check the arguments to avoid errors."};

  @override
  List<String> toCommand() {
    List<String> args = [];
    args.addAll(["-a", action.name, "-d", directory]);

    if (name != null) {
      args.addAll(["-n", name!]);
    }
    if (sourceGitUrl != null) {
      args.addAll(["-g", sourceGitUrl!]);
    }
    if (sourceBranch != null) {
      args.addAll(["-b", sourceBranch!]);
    }
    if (removeOtherBranches != null) {
      args.addAll(["-r", removeOtherBranches.toString()]);
    }
    if (force != null) {
      args.addAll(["-f", force.toString()]);
    }
    if (subpath != null) {
      args.addAll(["--subpath", subpath!]);
    }

    return args;
  }
}
