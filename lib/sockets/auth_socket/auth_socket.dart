import 'package:crypt/crypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:email_validator/email_validator.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:safely_net_api/db_connection/db_connection.dart';
import 'package:safely_net_api/sockets/auth_socket/auth_socket_event.dart';
import 'package:safely_net_api/tools/auth_tools/password_validator.dart';
import 'package:safely_net_api/tools/auth_tools/send_activation_email.dart';
import 'package:safely_net_api/tools/configs/secret.dart';
import 'package:safely_net_api/tools/reponse_tools/code_to_error.dart';

class AuthSocket {
  final dynamic client;

  AuthSocket(this.client);

  onRegister() async {
    client.on(AuthSocketEvent.register, (data) async {
      //email and password in data as json
      String? _email = data["email"];
      String? _password = data["password"];
      //validate email and password
      bool _isValidEmail = EmailValidator.validate(_email!);
      bool _isValidPassword = PasswordValidator(_password!).isPasswordValid;

      if (!_isValidEmail) {
        return client.emit(AuthSocketEvent.register, {
          "error": true,
          "title": "Error",
          "message": "Please Enter Valid Email",
        });
      }

      if (!_isValidPassword) {
        return client.emit(AuthSocketEvent.register, {
          "error": true,
          "title": "Error",
          "message":
              "Please Enter Strong Password with atlease one uppercase case and one special characters.",
        });
      }

      Db _db = await DBConnection.connect();
      DbCollection _authCollection = _db.collection('auths');

      //if not then hash password then save into database
      String _hashedPassword = Crypt.sha256(_password, salt: '10').toString();

      return await _authCollection.legacyInsert({
        "email": _email,
        "password": _hashedPassword,
        "isVerified": false,
        "createdAt": DateTime.now(),
      }).then((value) async {
        //send account activation link
        Map<String, dynamic>? _regUser =
            await _db.collection('auths').findOne({"email": _email});

        String _link = "http://localhost:8080/auth/activation/" +
            _regUser!["_id"].toHexString();

        await SendActivationEmail()
            .sendEmail(recipientEmail: _email, activationLink: _link);
        //

        //emit successfully registered
        return client.emit(AuthSocketEvent.register, {
          "error": false,
          "title": "Successful",
          "message":
              "Successfully Registered. Please check your email box to activate the account.",
        });
      }).catchError((error) {
        //emit error if something went wrong
        return client.emit(AuthSocketEvent.register, {
          "error": true,
          "title": "Error",
          "message": CodeToError.authErrorMessage(error["code"]),
        });
      });
    });
  }

  onLogin() async {
    client.on(AuthSocketEvent.login, (data) async {
      //email and password in data as json
      String? _email = data["email"];
      String? _password = data["password"];
      //validate email and password
      bool _isValidEmail = EmailValidator.validate(_email!);

      if (!_isValidEmail) {
        return client.emit(AuthSocketEvent.register, {
          "error": true,
          "title": "Error",
          "message": "Please Enter Valid Email",
        });
      }

      String _hashedPassword = Crypt.sha256(_password!, salt: '10').toString();

      Db _db = await DBConnection.connect();

      return await _db.collection('auths').legacyFindOne({
        "email": _email,
        "password": _hashedPassword,
      }).then((authJson) async {
        //check if account is verified
        String? _authToken;

        if (authJson!["isVerified"] == false) {
          return client.emit(AuthSocketEvent.login, {
            "error": true,
            "title": "Activate your account",
            "message": "Please check you email box to activate your account.",
            "token": _authToken,
          });
        }

        //Sign auth and create token
        JWT jwt = JWT({
          "_id": authJson["_id"],
          "email": authJson["email"],
          "isVerified": authJson["isVerified"],
          "createdAt": authJson["createdAt"].toString(),
        });
        _authToken = jwt.sign(SecretKey(Secret.authSecret));

        return client.emit(AuthSocketEvent.login, {
          "error": false,
          "title": "Successful",
          "message": "Successfully Logged In.",
          "token": _authToken,
        });
      }).catchError((error) {
        return client.emit(AuthSocketEvent.login, {
          "error": true,
          "title": "Login failed",
          "message": "Please enter valid email address or password.",
          "token": null,
        });
      });
    });
  }
}
