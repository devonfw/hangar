import 'package:takeoff_lib/src/domain/hangar_scripts/gcloud/account/setup_principal_account.dart';
import 'package:test/test.dart';

void main() {
  test("SetUpPrincipalAccountGCloud to command generates the arguments correctly", () {
    SetUpPrincipalAccountGCloud setUpPrincipalAccountGCloud = SetUpPrincipalAccountGCloud(googleAccount: "", serviceAccount: "TakeOff", projectId: "test1");
    expect(setUpPrincipalAccountGCloud.toCommand(), ['/scripts/accounts/gcloud/setup-principal-account.sh','-s','TakeOff','-p','test1','-f','/scripts/accounts/gcloud/predefined-roles.txt']);
  });

  test("SetUpPrincipalAccountGCloud to command with empty service account and all the parameters generates the arguments correctly", () {
    SetUpPrincipalAccountGCloud setUpPrincipalAccountGCloud = SetUpPrincipalAccountGCloud(googleAccount: "", serviceAccount: "", projectId: "", roles: "roles", customRoleYamlPath: "customRoleYamlPath", customRoleId: "customRoleId", serviceKeyPath: "serviceKeyPath");
    expect(setUpPrincipalAccountGCloud.toCommand(), ['/scripts/accounts/gcloud/setup-principal-account.sh','-g','','-p','','-f','/scripts/accounts/gcloud/predefined-roles.txt','-r','roles','-c','customRoleYamlPath','-i','customRoleId','-k','serviceKeyPath']);
  });

}
