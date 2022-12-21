import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';

/// Creates the intance of the Database
class DbFactory {
  DbFactory({String? dbPath})
      : _dbPath = dbPath ??
            join(GetIt.I.get<FoldersService>().getCacheFolder().path,
                "takeoff.db");

  /// Path to the file of the database in the cache folder
  final String _dbPath;

  /// Creates the [Database] instance
  Future<Database> create() async {
    return await databaseFactoryIo.openDatabase(_dbPath);
  }
}
