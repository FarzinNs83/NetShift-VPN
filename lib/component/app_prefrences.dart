// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:netshift_vpn/model/vpn_info.dart';

class AppPrefrences {
  static VpnInfo get VpnInfoObj =>
      VpnInfo.fromJson(jsonDecode(GetStorage().read('vpn') ?? '{}'));
  static set VpnInfoObj(VpnInfo value) =>
      GetStorage().write('vpn', jsonEncode(value.toJson()));
  static List<VpnInfo> get vpnList {
    List<VpnInfo> tempVpnList = [];
    final dataVpn = jsonDecode(GetStorage().read('vpnList') ?? '[]');
    for (var data in dataVpn) {
      tempVpnList.add(VpnInfo.fromJson(data));
    }
    return tempVpnList;
  }
  static set vpnList(List<VpnInfo> valueList) =>
      GetStorage().write('vpnList', jsonEncode(valueList));
}
