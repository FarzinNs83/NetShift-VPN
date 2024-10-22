
import 'package:get/get.dart';
import 'package:netshift_vpn/component/app_prefrences.dart';
import 'package:netshift_vpn/model/vpn_info.dart';

class HomeController extends GetxController {
  final Rx<VpnInfo> vpnInfo = AppPrefrences.VpnInfoObj.obs;
}


