import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netshift_vpn/theme_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  BottomSelection(BuildContext context) {
    return SafeArea(
      child: Semantics(
        button: true,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.redAccent,
            padding: EdgeInsets.symmetric(horizontal: Get.width * .041),
            height: 62,
            child: const Row(
              children: [
                Icon(
                  Icons.flag_circle,
                  color: Colors.white,
                  size: 36,
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  "Select a Country",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.redAccent,
                    size: 26,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text("NetShift VPN"),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return Obx(
              () => IconButton(
                onPressed: () {
                  themeController.toggleTheme();
                },
                icon: themeController.isDarkMode.value
                    ? const Icon(
                        Icons.wb_sunny_outlined,
                        color: Colors.amberAccent,
                      )
                    : const Icon(
                        Icons.nights_stay_outlined,
                        color: Colors.black45,
                      ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomSelection(context),
    );
  }
}
