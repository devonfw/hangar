import 'package:takeoff_lib/src/hangar_scripts/common/repo/create_repo.dart';

abstract class RepositoryController<T extends CreateRepo> {
  Future<bool> createRepository(T script);
}
