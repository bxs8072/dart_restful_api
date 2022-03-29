import 'package:mongo_dart/mongo_dart.dart';
import 'package:safely_net_api/db_connection/db_connection.dart';

class UserApi {
  Future<Map<String, dynamic>?> getUserById(String id) async {
    Db _db = await DBConnection.connect();

    DbCollection _userCollection = _db.collection('users');

    Map<String, dynamic>? _userJson =
        await _userCollection.findOne({"_id": ObjectId.parse(id)});
    if (_userJson == null) {
      return null;
    }
    return _userJson;
  }

  Future<List<Map<String, dynamic>>?> fetchActiveUsers(String userId) async {
    Db _db = await DBConnection.connect();

    DbCollection _roomCollection = _db.collection('rooms');

    List<ObjectId?> _users = [];

    for (var element in await _roomCollection
        .legacyFind(where.all('users', [userId]))
        .toList()) {
      for (var u in List.from(element["users"])) {
        Map<String, dynamic>? _user = await getUserById(u);
        _users.add(_user!["_id"]);
      }
    }

    DbCollection _userCollection = _db.collection('users');

    return _userCollection
        .legacyFind(
          where.ne('_id', ObjectId.parse(userId)).eq('active', true),
        )
        .toList();
  }
}
