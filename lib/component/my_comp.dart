import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {
  final String titleText;
  final String subtitle;
  final Widget icon;
  const CustomButtons({
    super.key,
    required this.titleText,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        // height: Get.height * 0.50,
        child: Column(
          children: [
            icon,
            const SizedBox(
              height: 6,
            ),
            Text(
              titleText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ));
  }
}
