import 'package:safely_net_api/models/user.dart';

class Upload {
  String _id;
  final String size;
  final String fileName;
  final String url;
  final User uploader;

  Upload(
    this._id, {
    required this.size,
    required this.fileName,
    required this.url,
    required this.uploader,
  });

  String get id => _id;

  Map<String, dynamic> get toMap => {
        "_id": _id,
        "size": size,
        "fileName": fileName,
        "url": url,
        "uploader": uploader.toMap,
      };

  factory Upload.fromJson(dynamic jsonData) => Upload(
        jsonData["_id"] ?? "",
        size: jsonData["size"],
        fileName: jsonData["fileName"],
        url: jsonData["url"],
        uploader: User.fromJson(jsonData["uploader"]),
      );
}
