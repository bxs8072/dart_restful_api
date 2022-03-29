import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:safely_net_api/api/user_api.dart';
import 'package:safely_net_api/db_connection/db_connection.dart';
import 'package:safely_net_api/tools/configs/secret.dart';
import 'package:safely_net_api/tools/reponse_tools/code_to_error.dart';
import 'package:safely_net_api/tools/reponse_tools/json_response.dart';
import 'package:shelf_plus/shelf_plus.dart';

class UserRouter {
  static Handler get app {
    var router = Router().plus;

    const String createUserURL = "/user/create";
    const String getUserURL = "/user";
    UserApi _userApi = UserApi();

    router.get(getUserURL, (Request request) async {
      String _authToken = request.headers["authorization"]!;

      JWT jwt = JWT.verify(_authToken, SecretKey(Secret.authSecret));

      String _id = jwt.payload["_id"];

      Db _db = await DBConnection.connect();

      DbCollection _userCollection = _db.collection('users');

      return await _userCollection
          .findOne({"_id": ObjectId.parse(_id)}).then((value) async {
        return Future.sync(
          () => Response.ok(json.encode(
            JsonResponse(
              data: value,
              error: null,
              message: "Successfully created new user.",
              title: "Successful",
            ).toMap,
          )),
        );
      }).catchError((err) {
        return Future.sync(
          () => Response.ok(json.encode(
            JsonResponse(
              data: null,
              error: err["code"].toString(),
              message: CodeToError.authErrorMessage(err["code"]),
              title: "Failed",
            ).toMap,
          )),
        );
      });
    });

    router.post(createUserURL, (Request request) async {
      dynamic _jsonData = await request.body.asJson;

      String _authToken = request.headers["authorization"]!;

      JWT jwt = JWT.verify(_authToken, SecretKey(Secret.authSecret));

      String _id = jwt.payload["_id"];

      String _email = jwt.payload["email"];

      Map<String, dynamic> _user = {
        "_id": ObjectId.parse(_id),
        "name": _jsonData["name"],
        "email": _email,
        "phone": _jsonData["phone"] ?? "",
        "photo": _jsonData["photo"] ?? "",
        "location": {
          "latitude": 0.00,
          "longitude": 0.00,
        },
        "contacts": [],
        "active": false,
        "isTyping": false,
      };

      Db _db = await DBConnection.connect();

      DbCollection _userCollection = _db.collection('users');

      return await _userCollection.legacyInsert(_user).then((value) async {
        Map<String, dynamic>? _regUser =
            await _userCollection.findOne({"_id": ObjectId.parse(_id)});
        return Future.sync(
          () => Response.ok(json.encode(
            JsonResponse(
              data: _regUser,
              error: null,
              message: "Successfully created new user.",
              title: "Successful",
            ).toMap,
          )),
        );
      }).catchError((err) {
        return Future.sync(
          () => Response.ok(json.encode(
            JsonResponse(
              data: null,
              error: err["code"].toString(),
              message: CodeToError.authErrorMessage(err["code"]),
              title: "Failed",
            ).toMap,
          )),
        );
      });
    });

    router.get('/user/active', (Request request) async {
      String _authToken = request.headers["authorization"]!;

      JWT jwt = JWT.verify(_authToken, SecretKey(Secret.authSecret));

      String _id = jwt.payload["_id"];

      Db _db = await DBConnection.connect();

      DbCollection _roomCollection = _db.collection('rooms');
      List<ObjectId?> _users = [];

      for (var element in await _roomCollection
          .legacyFind(where.all('users', [_id]))
          .toList()) {
        for (var u in List.from(element["users"])) {
          Map<String, dynamic>? _user = await _userApi.getUserById(u);
          _users.add(_user!["_id"]);
        }
      }
      DbCollection _userCollection = _db.collection('users');

      return _userCollection
          .legacyFind(
            where.ne('_id', ObjectId.parse(_id)).eq('active', true),
          )
          .toList()
          .then((value) async {
        return Future.sync(() async {
          return Response.ok(
            json.encode({
              "data": value,
              "error": null,
              "message": "Successfully fetched all active users.",
              "title": "Successful",
            }),
          );
        });
      });
    });
    return router;
  }
}
