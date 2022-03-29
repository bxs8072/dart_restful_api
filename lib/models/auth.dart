class Auth {
  String _id;
  final String email;
  final String password;
  final bool isVerified;
  final DateTime createdAt;

  Auth(this._id, this.email, this.password, this.isVerified, this.createdAt);

  String get id => _id;

  Map<String, dynamic> get toMap => {
        "_id": id,
        "email": email,
        "password": password,
        "isVerified": isVerified,
        "createdAt": createdAt,
      };

  factory Auth.fromJson(dynamic jsonData) => Auth(
        jsonData["_id"] ?? "",
        jsonData["email"],
        jsonData["password"],
        jsonData["isVerified"],
        jsonData["createdAt"],
      );
}
