import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:safely_net_api/db_connection/db_connection.dart';
import 'package:safely_net_api/sockets/user_socket/user_socket_event.dart';
import 'package:safely_net_api/tools/configs/secret.dart';
import 'package:socket_io/socket_io.dart' as IO;

class UserSocket {
  final dynamic client;
  final String? authToken;
  UserSocket({required this.client, this.authToken});

  onFetch() async {
    client.on(UserSocketEvent.fetch, (data) async {
      if (authToken == null) {
        return client.emit(UserSocketEvent.fetch, {
          "error": true,
          "title": "Error",
          "message": "You need to login to perform this action",
          "data": null,
        });
      }

      String? _id = data["_id"];

      Db _db = await DBConnection.connect();
      return await _db
          .collection("users")
          .legacyFindOne({"_id": ObjectId.parse(_id!)}).then((value) async {
        return client.emit(UserSocketEvent.fetch, {
          "error": false,
          "title": "Successful",
          "message": "User account found!",
          "data": value,
        });
      }).catchError((error) {
        return client.emit(UserSocketEvent.fetch, {
          "error": false,
          "title": "Account not existed",
          "message": "Create new account",
          "data": null,
        });
      });
    });
  }

  onInsert() async {
    client.on(UserSocketEvent.insert, (data) async {
      if (authToken == null) {
        return client.emit(UserSocketEvent.fetch, {
          "error": true,
          "title": "Error",
          "message": "You need to login to perform this action",
          "data": null,
        });
      }
      print(authToken);
      JWT _jwt = JWT.verify(authToken!, SecretKey(Secret.authSecret));

      String? _id = _jwt.payload["_id"];
      String? _email = _jwt.payload["email"];

      Db _db = await DBConnection.connect();
      return await _db.collection("users").legacyInsert({
        "_id": ObjectId.parse(_id!),
        "email": _email!,
        "name": data["name"],
        "phone": data["phone"],
        "photo": data["photo"],
        "location": {
          "latitude": 0.00,
          "longitude": 0.00,
        },
        "contacts": [],
        "active": false,
        "isTyping": false,
      }).then((value) async {
        return await _db
            .collection("users")
            .legacyFindOne({"_id": ObjectId.parse(_id)}).then((value) async {
          return client.emit(UserSocketEvent.fetch, {
            "error": false,
            "title": "Successful",
            "message": "User account found!",
            "data": value,
          });
        });
      }).catchError((error) {
        return client.emit(UserSocketEvent.fetch, {
          "error": false,
          "title": "Account not existed",
          "message": "Create new account",
          "data": null,
        });
      });
    });
  }
}
