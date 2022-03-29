import 'package:mongo_dart/mongo_dart.dart';
import 'package:safely_net_api/api/user_api.dart';
import 'package:safely_net_api/db_connection/db_connection.dart';

class RoomApi {
  Future<List<dynamic>?> fetchRooms(String userId) async {
    UserApi _userApi = UserApi();
    Db _db = await DBConnection.connect();

    DbCollection _roomCollection = _db.collection('rooms');

    List<dynamic>? _rooms = [];

    for (var element in await _roomCollection
        .legacyFind(where.all('users', [userId]))
        .toList()) {
      List<dynamic>? _users = [];

      for (var u in List.from(element["users"])) {
        _users.add(await _userApi.getUserById(u));
      }

      dynamic _parsedElement = {
        "_id": element["_id"],
        "users": _users,
        "createdAt": element["createdAt"].toString(),
        "updatedAt": element["updatedAt"].toString(),
      };

      _rooms.add(_parsedElement);
    }

    return _rooms;
  }
}
