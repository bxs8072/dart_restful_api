import 'package:safely_net_api/routers/auth_router.dart';
import 'package:safely_net_api/routers/room_router.dart';
import 'package:safely_net_api/routers/user_router.dart';
import 'package:safely_net_api/sockets/socket_service.dart';
import 'package:safely_net_api/tools/configs/server_config.dart';

import 'package:shelf_plus/shelf_plus.dart';

void main() {
  SocketService().initSocket();
} 

// Handler init() {
//   SocketService().initSocket();
//   return cascade([AuthRouter.app, UserRouter.app, RoomRouter.app]);
// }

// nodemon -x "dart run bin/server.dart " -e dart

