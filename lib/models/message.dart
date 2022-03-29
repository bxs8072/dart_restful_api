import 'package:safely_net_api/models/room.dart';
import 'package:safely_net_api/models/user.dart';

class Message {
  String _id;
  final Room room;
  final String content;
  final String contentType;
  final User sender;
  final DateTime createdAt;

  Message(
    this._id, {
    required this.room,
    required this.content,
    required this.contentType,
    required this.sender,
    required this.createdAt,
  });

  String get id => _id;

  Map<String, dynamic> get toMap => {
        "_id": _id,
        "room": room.toMap,
        "content": content,
        "contentType": contentType,
        "sender": sender.toMap,
        "createdAt": createdAt.toIso8601String(),
      };

  factory Message.fromJson(dynamic jsonData) => Message(
        jsonData["_id"] ?? "",
        room: Room.fromJson(jsonData["room"]),
        content: jsonData["content"],
        contentType: jsonData["contentType"],
        sender: User.fromJson(jsonData["sender"]),
        createdAt: DateTime.parse(jsonData["createdAt"]),
      );
}
