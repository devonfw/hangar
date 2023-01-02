import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:takeoff_gui/features/create/controllers/create_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:takeoff_gui/features/create/utils/provider_ci_cd.dart';
import 'package:takeoff_gui/features/create/widgets/repo_selector.dart';

import '../../../../common/test_widget.dart';
import 'repo_selector_test.mocks.dart';

@GenerateNiceMocks([MockSpec<CreateController>()])
void main() async {
  MockCreateController mockCreateController = MockCreateController();

  setUpAll(() async {
    GetIt.I.registerSingleton<CreateController>(mockCreateController);
  });

  testWidgets('Widget has correct data', (tester) async {
    await tester.pumpWidget(TestWidget(child: RepoSelector()));

    expect(find.text("Select a repo & CI/CD provider"), findsOneWidget);
    expect(mockCreateController.repoProvider, ProviderCICD.github);

    bool result =
        mockCreateController.providersCICD.contains(ProviderCICD.gcloud);
    expect(result, false);

    result =
        mockCreateController.providersCICD.contains(ProviderCICD.azureDevOps);
    expect(result, false);

    result = mockCreateController.providersCICD.contains(ProviderCICD.github);
    expect(result, false);

    when(mockCreateController.providersCICD.contains(ProviderCICD.gcloud))
        .thenReturn(true);
  });
}
