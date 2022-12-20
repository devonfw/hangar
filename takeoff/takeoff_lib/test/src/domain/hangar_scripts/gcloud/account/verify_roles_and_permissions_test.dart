import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/account/verify_roles_and_permissions.dart';
import 'package:test/test.dart';

void main() {
  test("VerifyRolesAndPermissionsGCloud to command generates the arguments correctly", () {
    VerifyRolesAndPermissionsGCloud verifyRolesAndPermissionsGCloud = VerifyRolesAndPermissionsGCloud(googleAccount: "", serviceAccount: "serviceAccount", projectId: "projectId");
    expect(verifyRolesAndPermissionsGCloud.toCommand(), ['/scripts/accounts/gcloud/verify-principal-roles-and-permissions.sh','-s','serviceAccount','-p','projectId','-f','/scripts/accounts/gcloud/predefined-roles.txt']);
  });

  test("VerifyRolesAndPermissionsGCloud to command with empty service account and all the parameters generates the arguments correctly", () {
    VerifyRolesAndPermissionsGCloud verifyRolesAndPermissionsGCloud = VerifyRolesAndPermissionsGCloud(googleAccount: "", serviceAccount: "", projectId: "",roles: "roles", permissions: "permissions", permissionsFilePath: "permissionsFilePath");
    expect(verifyRolesAndPermissionsGCloud.toCommand(), ['/scripts/accounts/gcloud/verify-principal-roles-and-permissions.sh','-g','','-p','','-f','/scripts/accounts/gcloud/predefined-roles.txt','-r','roles','-e','permissions','-i','permissionsFilePath']);
  });  

}
