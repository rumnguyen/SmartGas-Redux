class API {
  static const String domain = "http://speedaiot.ddns.net:1337";

  static const String portalDomain = "http://speedaiot.ddns.net:8000";

  static const int requestTimeOut = 60; // Unit: seconds

  static String getApiUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }

    return domain + endpoint;
  }
}
