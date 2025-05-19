import 'package:flutter/material.dart';
import 'package:adoption_ui_app/theme/color.dart';

class ProfileUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom AppBar with Gradient
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.purple, AppColor.purple.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      _buildProfilePicture(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  // User Name and Email
                  Text(
                    "John Doe",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "johndoe@email.com",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColor.labelColor.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Status or Bio
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColor.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Pet Lover | Adopter",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.mainColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Profile Options with Animation
                  _buildProfileOption(
                    icon: Icons.edit,
                    text: "Edit Profile",
                    onTap: () {
                      // Navigate to Edit Profile Page
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.settings,
                    text: "Settings",
                    onTap: () {
                      // Navigate to Settings Page
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.logout,
                    text: "Log Out",
                    onTap: () {
                      // Handle Logout
                    },
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Profile Picture
  Widget _buildProfilePicture() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColor.purple.withOpacity(0.3), Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage("assets/images/profile.png"),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.purple,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Enhanced Profile Option Item with Animation
  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLogout
                ? [Colors.redAccent.withOpacity(0.1), Colors.transparent]
                : [AppColor.cardColor, AppColor.cardColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.redAccent : AppColor.mainColor,
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isLogout ? Colors.redAccent : AppColor.mainColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColor.labelColor.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}