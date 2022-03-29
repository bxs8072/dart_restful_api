import 'package:safely_net_api/models/user.dart';

class Room {
  String _id;
  final List<String> users;
  final DateTime createdAt, updatedAt;

  Room(
    this._id, {
    required this.users,
    required this.createdAt,
    required this.updatedAt,
  });

  String get id => _id;

  Map<String, dynamic> get toMap => {
        "_id": _id,
        "users": users,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };

  factory Room.fromJson(dynamic jsonData) => Room(
        (jsonData["_id"]) ?? "",
        createdAt: jsonData["createdAt"],
        updatedAt: jsonData["updatedAt"],
        users: jsonData["users"],
      );
}
