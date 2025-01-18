class AppConfig {
  static const bool debug = true;
  static const String serverIp = '127.0.0.1';
  static const String port = '8080'; // Replace with your actual port
  static const String baseUrl =
      debug ? 'http://$serverIp:$port/api' : 'https://$serverIp:$port/api';
}
