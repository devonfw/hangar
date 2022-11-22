// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/src/hangar_scripts/script.dart';

/// Checks if a Principal (end user or service account) has the specified roles and permissions in a given project.
class VerifyRolesAndPermissionsGCloud implements Script {
  /// Google Account of an end user. Mutually exclusive with [serviceAccount].
  String googleAccount;

  /// Service Account Name. Mutually exclusive with [googleAccount].
  String serviceAccount;

  /// Short project name (ID) where the roles and permissions will be checked.
  String projectId;

  /// Roles to be checked, splitted by comma.
  String? roles;

  /// Path to a file containing the roles to be checked.
  String rolesFilePath;

  /// Permissions to be checked, splitted by comma.
  String? permissions;

  /// Path to a file containing the permissions to be checked.
  String? permissionsFilePath;

  VerifyRolesAndPermissionsGCloud({
    required this.googleAccount,
    required this.serviceAccount,
    required this.projectId,
    this.roles,
    this.rolesFilePath = "/scripts/accounts/gcloud/predefined-roles.txt",
    this.permissions,
    this.permissionsFilePath,
  });

  @override
  Map<int, String> get errors => {
        2: "There was an error related to the account or parameters.\nCheck the arguments to avoid errors.",
        127: "Google Cloud CLI is not installed",
        3: "There was an error checking a role or permission",
      };

  @override
  List<String> toCommand() {
    List<String> args = [
      "/scripts/accounts/gcloud/verify-principal-roles-and-permissions.sh"
    ];
    if (serviceAccount.isNotEmpty) {
      args.addAll(["-s", serviceAccount]);
    } else {
      args.addAll(["-g", googleAccount]);
    }
    args.addAll(["-p", projectId, "-f", rolesFilePath]);
    if (roles != null) {
      args.addAll(["-r", roles!]);
    }
    if (permissions != null) {
      args.addAll(["-e", permissions!]);
    }
    if (permissionsFilePath != null) {
      args.addAll(["-i", permissionsFilePath!]);
    }

    return args;
  }
}
