import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:takeoff_lib/src/utils/folders/folders_service.dart';

class DatabaseSingleton {
  static final String _dbPath = "${FoldersService.getCacheFolder()}takeoff.db";

  static final DatabaseFactory _dbFactory = databaseFactoryIo;

  static Database? _db;

  static Future<Database> getInstance() async {
    _db ??= await _dbFactory.openDatabase(_dbPath);

    return _db!;
  }
}
