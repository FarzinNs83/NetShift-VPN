import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:netshift_vpn/light_dark_theme.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;
  final _storage = GetStorage();
  final storageKey = 'isDarkMode';

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _loadTheme();
    Get.changeTheme(isDarkMode.value ? darkTheme : lightTheme);
  }

  bool _loadTheme() {
    return _storage.read(storageKey) ?? false;
  }

  void _saveTheme(bool isDarkMode) {
    _storage.write(storageKey, isDarkMode);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(isDarkMode.value ? darkTheme : lightTheme);
    _saveTheme(isDarkMode.value);
  }
}
