import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';

/// Creates the intance of the Database
class DatabaseSingleton {
  /// Path to the file of the database in the cache folder
  static final String _dbPath =
      join(FoldersService.getCacheFolder().path, "takeoff.db");

  /// Database factory used to create the database
  static final DatabaseFactory _dbFactory = databaseFactoryIo;

  /// Creates the [Database] instance
  static Future<Database> initialize() async {
    return await _dbFactory.openDatabase(_dbPath);
  }
}
