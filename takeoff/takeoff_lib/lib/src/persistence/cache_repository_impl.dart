import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:takeoff_lib/src/controllers/persistence/cache_repository.dart';

class CacheRepositoryImpl extends CacheRepository {
  /// Key to access to the Google Cloud email record
  final String _googleCloudKey = 'gcloud_email';

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
}
