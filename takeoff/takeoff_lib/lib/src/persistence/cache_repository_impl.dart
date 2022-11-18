import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';

class CacheRepositoryImpl extends CacheRepository {
  /// Key to access to the Google Cloud email record
  final String _googleCloudKey = 'gcloud_email';

  final String _googleProjectIdsKey = 'gcloud_project_ids';

  @override
  Future<bool> saveGoogleEmail(String email) async {
    Database db = GetIt.I.get<Database>();

    StoreRef store = StoreRef.main();

    await store.record(_googleCloudKey).put(db, email);

    return true;
  }

  @override
  Future<String> getGoogleEmail() async {
    Database db = GetIt.I.get<Database>();

    StoreRef store = StoreRef.main();

    String? email = await store.record(_googleCloudKey).get(db);

    return email ?? "";
  }

  @override
  Future<bool> saveGoogleProjectId(String projectId) async {
    Database db = GetIt.I.get<Database>();

    StoreRef store = StoreRef.main();

    String email = await getGoogleEmail();

    // It's necessary that this list is List<dynamic> because sembast returns
    //an ImmutableList<dynamic>?, which cannot be casted to List<String>?.
    List<dynamic>? ids =
        await store.record("${email}_$_googleProjectIdsKey").get(db);

    ids ??= [];

    // Because ids is an immutable list of dynamic type, we have to transform
    // each element to String and create a new list that is not read only.
    List<String> newList = ids.map((e) => e.toString()).toList();
    newList.add(projectId);

    await store.record("${email}_$_googleProjectIdsKey").put(db, newList);

    return true;
  }

  @override
  Future<List<String>> getGoogleProjectIds() async {
    Database db = GetIt.I.get<Database>();

    StoreRef store = StoreRef.main();

    String email = await getGoogleEmail();
    List<dynamic>? ids =
        await store.record("${email}_$_googleProjectIdsKey").get(db);

    ids ??= [];

    List<String> res = ids.map((e) => e.toString()).toList();

    return res;
  }

  @override
  Future<bool> removeGoogleProject(String projectId) async {
    Database db = GetIt.I.get<Database>();

    StoreRef store = StoreRef.main();

    String email = await getGoogleEmail();
    List<dynamic>? ids =
        await store.record("${email}_$_googleProjectIdsKey").get(db);

    ids ??= [];
    if (ids.isEmpty) return true;

    List<String> newList = ids.map((e) => e.toString()).toList();
    newList.remove(projectId);

    await store.record("${email}_$_googleProjectIdsKey").put(db, newList);

    return true;
  }
}
