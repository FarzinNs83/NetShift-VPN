class VpnInfo {
  late final String hostname;
  late final String ip;
  late final String ping;
  late final int speed;
  late final String contryLongName;
  late final String contryShortName;
  late final int vpnSessionsNum;
  late final String base64OpenVPNConfigurationData;

  VpnInfo(
      {required this.hostname,
      required this.ip,
      required this.ping,
      required this.speed,
      required this.contryLongName,
      required this.contryShortName,
      required this.vpnSessionsNum,
      required this.base64OpenVPNConfigurationData});

  VpnInfo.fromJson(Map<String, dynamic> json) {
    hostname = json['HostName'] ?? '';
    ip = json['IP'] ?? '';
    ping = json['Ping'] ?? 0;
    speed = json['Speed'];
    contryLongName = json['ContryLongName'] ?? '';
    contryShortName = json['ContryShortName'];
    vpnSessionsNum = json['NumVpnSessions'];
    base64OpenVPNConfigurationData = json['OpenVPN_ConfigData_Base64'] ?? '';
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['HostName'] = hostname;
    data['IP'] = ip;
    data['Ping'] = ping;
    data['Speed'] = speed;
    data['ContryLongName'] = contryLongName;
    data['ContryShortName'] = contryShortName;
    data['NumVpnSessions'] = vpnSessionsNum;
    data['OpenVPN_ConfigData_Base64'] = base64OpenVPNConfigurationData;
    return data;
  }
}
