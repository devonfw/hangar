import 'package:takeoff_lib/src/hangar_scripts/common/repo/create_repo.dart';

class CreateRepoGCloud extends CreateRepo {
  /// Short name (ID) of the Google Cloud project.
  String project;

  CreateRepoGCloud({
    required this.project,
    required super.action,
    required super.directory,
    super.name,
    super.sourceGitUrl,
    super.sourceBranch,
    super.removeOtherBranches,
    super.setUpBranchStrategy,
    super.force,
    super.subpath,
  });

  @override
  List<String> toCommand() {
    List<String> args = super.toCommand();
    args.insertAll(
        0, ["/scripts/repositories/gcloud/create-repo.sh", "-p", project]);

    return args;
  }
}
