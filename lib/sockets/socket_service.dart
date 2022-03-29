import 'package:safely_net_api/api/room_api.dart';
import 'package:safely_net_api/api/user_api.dart';
import 'package:safely_net_api/sockets/auth_socket/auth_socket.dart';
import 'package:safely_net_api/sockets/socket_type.dart';
import 'package:safely_net_api/sockets/user_socket/user_socket.dart';
import 'package:socket_io/socket_io.dart' as IO;

class SocketService {
  initSocket() {
    IO.Server io = IO.Server();

    io.on('connection', (client) {
      print("client connected");

      print(client.handshake);

      String? _authToken = client.handshake["query"]["auth-token"];

      print(_authToken);

      AuthSocket(client).onRegister();
      AuthSocket(client).onLogin();

      UserSocket(client: client, authToken: _authToken).onFetch();
      UserSocket(client: client, authToken: _authToken).onInsert();

      //  dynamic query = client.handshake["query"];

      // String? _id = query['userId'];

      // if (_id == null) {
      //   print("Login to to perform this action");
      // } else {
      //   client.on("service", (data) async {
      //     String? _socketType = data["socket-type"];

      //     if (_socketType == SocketType.fetchActiveUsers) {
      //       UserApi().fetchActiveUsers(_id).then((value) {
      //         client.emit(SocketType.fetchActiveUsers, value);
      //       });
      //     } else if (_socketType == SocketType.fetchRooms) {
      //       RoomApi().fetchRooms(_id).then((value) {
      //         client.emit(SocketType.fetchRooms, value);
      //       });
      //     }
      //   });
      // }
    });
    io.listen(3000);
  }
}
