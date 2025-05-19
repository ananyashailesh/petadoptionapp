import 'package:flutter/material.dart';


class BottomBarItem extends StatelessWidget {
  final Icon icon;
  final bool isActive;
  final Color activeColor;
  final GestureTapCallback onTap;

  const BottomBarItem(
    this.icon, {
    Key? key,
    this.isActive = false,
    required this.activeColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(bottom: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(
                color: isActive ? activeColor : Colors.grey,
                size: 26,
              ),
              child: icon,
            ),
          ],
        ),
      ),
    );
  }
}
