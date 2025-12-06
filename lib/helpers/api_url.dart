class ApiUrl {
  // - Android Emulator: 10.0.2.2 (alias ke host machine)
  // - Physical Device: 192.168.1.4 (Wi-Fi IP host machine)
  // - Web: localhost:8080 (running on browser)
  static const String baseUrl = "http://10.0.2.2:8080";

  static const String registrasi = "$baseUrl/register";
  static const String login = "$baseUrl/login";

  static const String listInventaris = "$baseUrl/inventaris";
  static const String createInventaris = "$baseUrl/inventaris";

  static String updateInventaris(int id) {
    return "$baseUrl/inventaris/$id";
  }

  static String showInventaris(int id) {
    return "$baseUrl/inventaris/$id";
  }

  static String deleteInventaris(int id) {
    return "$baseUrl/inventaris/$id";
  }
}
