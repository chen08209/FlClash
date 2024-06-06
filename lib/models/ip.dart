class IpInfo {
  final String ip;
  final String countryCode;

  const IpInfo({
    required this.ip,
    required this.countryCode,
  });

  static IpInfo fromIpInfoIoJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "ip": final String ip,
        "country": final String country,
      } =>
        IpInfo(
          ip: ip,
          countryCode: country,
        ),
      _ => throw const FormatException("invalid json"),
    };
  }

  static IpInfo fromIpApiCoJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "ip": final String ip,
        "country_code": final String countryCode,
      } =>
        IpInfo(
          ip: ip,
          countryCode: countryCode,
        ),
      _ => throw const FormatException("invalid json"),
    };
  }

  static IpInfo fromIpSbJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "ip": final String ip,
        "country_code": final String countryCode,
      } =>
        IpInfo(
          ip: ip,
          countryCode: countryCode,
        ),
      _ => throw const FormatException("invalid json"),
    };
  }

  static IpInfo fromIpwhoIsJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "ip": final String ip,
        "country_code": final String countryCode,
      } =>
        IpInfo(
          ip: ip,
          countryCode: countryCode,
        ),
      _ => throw const FormatException("invalid json"),
    };
  }

  @override
  String toString() {
    return 'IpInfo{ip: $ip, countryCode: $countryCode}';
  }
}
