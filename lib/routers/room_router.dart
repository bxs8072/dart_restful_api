import 'dart:convert';
import 'dart:ffi';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:safely_net_api/api/user_api.dart';
import 'package:safely_net_api/db_connection/db_connection.dart';
import 'package:safely_net_api/models/room.dart';
import 'package:safely_net_api/models/user.dart';
import 'package:safely_net_api/tools/configs/secret.dart';
import 'package:shelf_plus/shelf_plus.dart';

class RoomRouter {
  static Handler get app {
    var router = Router().plus;

    const String createRoomURL = "/room/create";
    const String getRoomURL = "/room";
    const String getAllRoomsURL = "/room/all";
    const String sendActivationCodeURL = "/auth/send-activation";

    UserApi _userApi = UserApi();

    router.get(getAllRoomsURL, (Request request) async {
      String _authToken = request.headers["authorization"]!;

      JWT jwt = JWT.verify(_authToken, SecretKey(Secret.authSecret));

      String _id = jwt.payload["_id"];

      ObjectId id = ObjectId.parse(_id);

      Db _db = await DBConnection.connect();

      DbCollection _roomCollection = _db.collection('rooms');

      List<Map<String, dynamic>> _rooms = [];

      for (var element in await _roomCollection
          .legacyFind(where.all('users', [_id]))
          .toList()) {
        List<Map<String, dynamic>?> _users = [];

        for (var u in List.from(element["users"])) {
          _users.add(await _userApi.getUserById(u));
        }

        var _parsedElement = {
          "_id": element["_id"],
          "users": _users,
          "createdAt": element["createdAt"].toString(),
          "updatedAt": element["updatedAt"].toString(),
        };

        _rooms.add(_parsedElement);
      }

      return Future.sync(
        () async => Response.ok(json.encode({
          "data": _rooms,
        })),
      );
    });

    router.post(getRoomURL, (Request request) async {
      String _authToken = request.headers["authorization"]!;

      JWT jwt = JWT.verify(_authToken, SecretKey(Secret.authSecret));

      String _id = jwt.payload["_id"];

      ObjectId id = ObjectId.parse(_id);

      dynamic _jsonData = await request.body.asJson;

      ObjectId id2 = ObjectId.parse(_jsonData["_id"]);

      Db _db = await DBConnection.connect();

      DbCollection _roomCollection = _db.collection('rooms');

      return await _roomCollection
          .findOne(where.all('users', [_jsonData["_id"], _id]))
          .then((value) async {
        List<Map<String, dynamic>?> _users = [];

        for (var u in List.from(value!["users"])) {
          _users.add(await _userApi.getUserById(u));
        }

        Map<String, dynamic> _resData = {
          "_id": value["_id"],
          "users": _users,
          "createdAt": value["createdAt"].toString(),
          "updatedAt": value["updatedAt"].toString(),
        };

        return Future.sync(
          () => Response.ok(json.encode({
            "data": _resData,
          })),
        );
      });
    });

    router.post(createRoomURL, (Request request) async {});

    return router;
  }
}
