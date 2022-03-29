import 'dart:io';

class ServerConfig {
  static String ip = InternetAddress.anyIPv4.address;
  static int port = int.parse(Platform.environment['PORT'] ?? '8080');
}
