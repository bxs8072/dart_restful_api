import 'package:mongo_dart/mongo_dart.dart';
import 'package:safely_net_api/tools/configs/db_config.dart';

class DBConnection {
  static Future<Db> connect() async {
    Db _db = Db(DBConfig.dbURI);
    await _db.open();
    return _db;
  }

  static Future<void> get close async => Db(DBConfig.dbURI).close();
}
