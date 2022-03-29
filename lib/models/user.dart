class Name {
  final String firstName, lastName;

  final String? middleName;

  Name(this.firstName, this.middleName, this.lastName);

  Map<String, dynamic> get toMap => {
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
      };

  String get fullName => firstName + " " + middleName! + " " + lastName;

  String get initial =>
      firstName[0].toUpperCase() + ' ' + lastName[0].toUpperCase();

  factory Name.fromJson(dynamic jsonData) => Name(
        jsonData["firstName"],
        jsonData["middleName"] ?? "",
        jsonData["lastName"],
      );
}

class Location {
  final double latitude, longitude;

  Location(this.latitude, this.longitude);

  Map<String, dynamic> get toMap => {
        "latitude": latitude,
        "longitude": longitude,
      };

  factory Location.fromJson(dynamic jsonData) => Location(
        jsonData["latitude"],
        jsonData["longitude"],
      );
}

class Contact {
  final Name name;

  final String email, phone, photo;

  Contact({
    required this.name,
    required this.email,
    required this.phone,
    required this.photo,
  });

  Map<String, dynamic> get toMap => {
        "name": name.toMap,
        "email": email,
        "phone": phone,
        "photo": photo,
      };

  factory Contact.fromJson(dynamic jsonData) => Contact(
        email: jsonData["email"],
        name: Name.fromJson(jsonData["name"]),
        phone: jsonData["phone"],
        photo: jsonData["photo"],
      );
}

class User {
  String _id;
  final Name name;
  final String email;
  final String phone;
  final String photo;
  final Location location;
  final List<Contact> contacts;
  final bool active;
  final bool isTyping;

  User(
    this._id, {
    required this.name,
    required this.email,
    required this.phone,
    required this.photo,
    required this.location,
    required this.contacts,
    required this.active,
    required this.isTyping,
  });

  String get id => _id;

  Map<String, dynamic> get toMap => {
        "_id": _id,
        "email": email,
        "name": name.toMap,
        "phone": phone,
        "photo": photo,
        "location": location.toMap,
        "contacts": contacts.map((e) => e.toMap).toList(),
        "active": active,
        "isTyping": isTyping,
      };

  factory User.fromJson(dynamic jsonData) => User(
        jsonData["_id"] ?? "",
        email: jsonData["email"],
        name: Name.fromJson(jsonData["name"]),
        phone: jsonData["phone"],
        photo: jsonData["photo"],
        contacts: List.from(jsonData["contacts"])
            .map((e) => Contact.fromJson(e))
            .toList(),
        isTyping: jsonData["isTyping"],
        active: jsonData["active"],
        location: Location.fromJson(jsonData["location"]),
      );
}
