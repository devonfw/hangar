// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:takeoff_lib/src/hangar_scripts/script.dart';

/// Enrolls a Principal (end user or service account) in a project with the provided roles attached.
///
/// [serviceAcccount] & [googleAccount] are mutually exclusive. If one is passed, the other
/// should be an empty `String`. If both are passed, TakeOff will favour the Service Account.
class SetUpPrincipalAccountGCloud implements Script {
  /// Google Account of an end user. Mutually exclusive with [serviceAccount].
  String googleAccount;

  /// Service Account Name. Mutually exclusive with [googleAccount].
  String serviceAccount;

  /// Short project name (ID) to which the principal will be enrolled.
  String projectId;

  /// Roles (basic or predefined) to be attached to the principal in the project, splitted by comma.
  String? roles;

  /// Path to a file containing the roles (basic or predefined) to be attached to the principal in the project.
  String rolesFilePath;

  /// Path to a YAML file containing the custom role to be attached to the principal in the project. Requires [customRoleId].
  String? customRoleYamlPath;

  /// ID to be set to the custom role provided in [customRoleYamlPath].
  String? customRoleId;

  SetUpPrincipalAccountGCloud({
    required this.googleAccount,
    required this.serviceAccount,
    required this.projectId,
    this.roles,
    this.rolesFilePath = "/scripts/accounts/gcloud/predefined-roles.txt",
    this.customRoleYamlPath,
    this.customRoleId,
  });

  @override
  Map<int, String> get errors => {
        2: "There was an error setting up the account.\nCheck the arguments to avoid errors.",
        127: "Google Cloud CLI is not installed",
      };

  @override
  List<String> toCommand() {
    List<String> args = ["/scripts/accounts/gcloud/setup-principal-account.sh"];
    if (serviceAccount.isEmpty) {
      args.addAll(["-s", serviceAccount]);
    } else {
      args.addAll(["-g", googleAccount]);
    }
    args.addAll(["-p", projectId, "-f", rolesFilePath]);

    if (roles != null) {
      args.addAll(["-r", roles!]);
    }
    if (customRoleYamlPath != null && customRoleId != null) {
      args.addAll(["-c", customRoleYamlPath!, "-i", customRoleId!]);
    }

    return args;
  }
}
