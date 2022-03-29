import 'package:mongo_dart/mongo_dart.dart';
import 'package:safely_net_api/db_connection/db_connection.dart';

class CreateIndex {
  Future<void> createAuthIndex() async {
    Db _db = await DBConnection.connect();

    // _db.collection('auths').createIndex(
    //     key: "email",
    //     unique: true,
    //     modernReply: true,
    //     name: "Auth with email already existed");
  }

  Future<void> createUserIndex() async {
    Db _db = await DBConnection.connect();

    // _db.collection('users').createIndex(

    //     unique: true,
    //     modernReply: true,
    //     name: "User with email already existed");
  }
}
