class AppConfig {
  static const bool debug = false;
  static const String serverIp = '10.0.2.2';
  static const String port = '8001'; // Replace with your actual port
  static const String baseUrl = debug ? 'http://$serverIp:$port/api' : 'https://$serverIp:$port/api';
}
