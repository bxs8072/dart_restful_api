import 'dart:convert';
import 'package:crypt/crypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:safely_net_api/db_connection/db_connection.dart';
import 'package:safely_net_api/tools/configs/secret.dart';
import 'package:safely_net_api/tools/auth_tools/send_activation_email.dart';
import 'package:safely_net_api/tools/reponse_tools/code_to_error.dart';
import 'package:safely_net_api/tools/reponse_tools/json_response.dart';
import 'package:shelf_plus/shelf_plus.dart';

class AuthRouter {
  static Handler get app {
    var router = Router().plus;

    const String registerURL = "/auth/register";
    const String loginURL = "/auth/login";
    const String activationURL = "/auth/activation/<id>";
    const String sendActivationCodeURL = "/auth/send-activation";

    router.post(registerURL, (Request request) async {
      dynamic _jsonData = await request.body.asJson;

      String _email = _jsonData["email"].toString().toLowerCase().trim();

      String hashedPassword =
          Crypt.sha256(_jsonData["password"], salt: '10').toString();

      Map<String, dynamic> _auth = {
        "email": _email,
        "password": hashedPassword,
        "isVerified": false,
        "createdAt": DateTime.now(),
      };

      print(_auth);

      Db _db = await DBConnection.connect();

      return await _db
          .collection('auths')
          .legacyInsert(_auth)
          .then((value) async {
        print(value);

        Map<String, dynamic>? _regUser =
            await _db.collection('auths').findOne({"email": _email});

        String _link = "http://localhost:8080/auth/activation/" +
            _regUser!["_id"].toHexString();

        await SendActivationEmail().sendEmail(
            recipientEmail: _regUser["email"], activationLink: _link);

        return Future.sync(
          () => Response.ok(json.encode(
            JsonResponse(
              data: {"email": _email},
              error: null,
              message:
                  "Successfully registered new account. Please check your email to activate the account.",
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

    router.post(loginURL, (Request request) async {
      dynamic _jsonData = await request.body.asJson;

      String _email = _jsonData["email"].toString().toLowerCase().trim();

      String hashedPassword =
          Crypt.sha256(_jsonData["password"], salt: '10').toString();

      Db _db = await DBConnection.connect();

      return await _db.collection('auths').legacyFindOne({
        "email": _email,
        "password": hashedPassword,
      }).then((value) async {
        Map<String, dynamic> _resData = {
          "_id": value!["_id"],
          "email": value["email"],
          "isVerified": value["isVerified"],
          "createdAt": value["createdAt"].toString(),
        };

        String? _authToken;

        if (_resData["isVerified"] == false) {
          return Future.sync(
            () => Response.forbidden(
              json.encode(JsonResponse(
                title: "Verify your account",
                message: "Check your email box to verify the account",
                data: null,
                error: "Please verify your account first!",
              ).toMap),
            ),
          );
        } else {
          final jwt = JWT(_resData);
          _authToken = jwt.sign(SecretKey(Secret.authSecret));
          return Future.sync(
            () => Response.ok(
              json.encode(JsonResponse(
                title: "Successful",
                message: "Successfully logged in",
                data: {"auth-token": _authToken},
                error: null,
              ).toMap),
            ),
          );
        }
      }).catchError((err) {
        return Future.sync(
          () => Response.forbidden(json.encode({
            "title": "Failed",
            "message": "Invalid email and password",
            "data": null,
            "error": err.toString(),
          })),
        );
      });
    });

    router.get(activationURL, (Request request) async {
      String _id = request.params["id"]!;
      Db _db = await DBConnection.connect();

      return await _db.collection('auths').modernUpdate(
        {"_id": ObjectId.fromHexString(_id)},
        ModifierBuilder().set('isVerified', true),
        upsert: false,
      ).then((value) {
        print(value);
        return Future.sync(() {
          return Response.ok(json.encode({
            "title": "success",
            "message": "Successfully verified user",
            "data": null,
            "error": {},
          }));
        });
      }).catchError((error) {
        return Future.sync(() {
          return Response.ok(json.encode({
            "title": "Failed",
            "message": "Fail to verified user",
            "data": null,
            "error": error.toString(),
          }));
        });
      });
    });

    router.post(sendActivationCodeURL, (Request request) async {
      dynamic _jsonData = await request.body.asJson;

      String _email = _jsonData["email"].toString().toLowerCase().trim();

      Db _db = await DBConnection.connect();

      Map<String, dynamic>? _regUser =
          await _db.collection('auths').findOne({"email": _email});

      String _link = "http://localhost:8080/auth/activation/" +
          _regUser!["_id"].toHexString();

      await SendActivationEmail()
          .sendEmail(recipientEmail: _regUser["email"], activationLink: _link);
    });
    return router;
  }
}
