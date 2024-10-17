// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netshift_vpn/component/my_comp.dart';
import 'package:netshift_vpn/controller/theme_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  // ignore: non_constant_identifier_names
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

  Widget vpnButton() {
    return Column(
      children: [
        Semantics(
          button: true,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent,
              ),
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                ),
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent,
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.power_settings_new,size: 80,
                        color: Colors.white,
                      ),
                      Text("Tap To Connect",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold,),),
                    ],
                  ),
                ),
              ),
            ),
            
          ),
        )
      ],
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
      body: SingleChildScrollView(
        child:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  CustomButtons(
                    titleText: "Location",
                    subtitle: "FREE",
                    icon: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.redAccent,
                      child: Icon(
                        Icons.flag_circle,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  CustomButtons(
                    titleText: "Ping",
                    subtitle: "60 Ms",
                    icon: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.redAccent,
                      child: Icon(
                        Icons.graphic_eq,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 60,
              ),
              vpnButton(),
              SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  CustomButtons(
                    titleText: "Download",
                    subtitle: "100 mbps",
                    icon: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.redAccent,
                      child: Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  CustomButtons(
                    titleText: "Upload",
                    subtitle: "50 mbps",
                    icon: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.redAccent,
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
