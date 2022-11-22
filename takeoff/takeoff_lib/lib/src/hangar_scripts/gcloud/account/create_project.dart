import 'package:takeoff_lib/src/hangar_scripts/script.dart';

/// Creates a new project and enables billing and required APIs.
class CreateProjectGCloud implements Script {
  /// Name of the new project.
  String projectName;

  /// Billing account. If not specified, won't be able to enable some services.
  String billingAccount;

  /// Description for the new project. If not specified, name will be used as description.
  String? description;

  /// ID of the folder for which the project will be configured.
  String? folderId;

  /// ID of the organization for which the project will be configured.
  String? organizationId;

  CreateProjectGCloud(
      {required this.projectName,
      required this.billingAccount,
      this.description,
      this.folderId,
      this.organizationId});

  @override
  Map<int, String> get errors => {
        2: "Missing mandatory parameters: Project name & Billing account",
        127: "GCloug CLI is not installed",
        200: "Error while creating the project",
        210: "Unable to link project to billing account",
        220: "Cannot enable Cloud Source Repositories API",
        221: "Cannot enable Cloud Run API",
        222: "Cannot enable Artifact Registry API",
        223: "Cannot enable Cloud Build API",
        224: "Cannot enable Secret Manager API"
      };

  @override
  List<String> toCommand() {
    List<String> args = [
      "/scripts/accounts/gcloud/create-project.sh",
      "-n",
      projectName,
      "-b",
      billingAccount
    ];
    if (description != null) {
      args.addAll(["-d", description!]);
    }
    if (folderId != null) {
      args.addAll(["-f", folderId!]);
    }
    if (organizationId != null) {
      args.addAll(["-o", organizationId!]);
    }
    return args;
  }
}
