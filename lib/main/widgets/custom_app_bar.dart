// adoption/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:adoption_ui_app/theme/color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;

  const CustomAppBar({
    Key? key,
    this.showBackButton = true,
    this.onBackPressed,
    this.onProfilePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.appBarColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColor.mainColor,
                    size: 24,
                  ),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        color: AppColor.labelColor,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Location",
                        style: TextStyle(
                          color: AppColor.labelColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Chennai, Tamil Nadu", // Hardcoded location
                    style: TextStyle(
                      color: AppColor.textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: AppColor.red.withOpacity(0.1),
              child: Icon(
                Icons.person_outline,
                color: AppColor.red,
                size: 24,
              ),
            ),
            onPressed: onProfilePressed ??
                () {
                  // Default profile navigation if no callback provided
                  // Navigator.pushNamed(context, '/profile');
                },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}