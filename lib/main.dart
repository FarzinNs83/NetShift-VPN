import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:netshift_vpn/view/home_page.dart';
import 'package:netshift_vpn/theme/light_dark_theme.dart';
import 'package:netshift_vpn/controller/theme_controller.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: themeController.isDarkMode.value ? darkTheme : lightTheme,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
