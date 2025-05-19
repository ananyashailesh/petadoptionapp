import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:adoption_ui_app/adoption/screens/adoption_dashboard.dart';
import 'package:adoption_ui_app/theme/color.dart';

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCard(
            context,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(
                    milliseconds: 300,
                  ), // Duration of animation
                  pageBuilder:
                      (context, animation, secondaryAnimation) => RootApp(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(
                          0,
                          1,
                        ), // Start position (bottom of screen)
                        end: Offset(0, 0), // End position (final screen)
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut, // Smooth transition
                        ),
                      ),
                      child: child,
                    );
                  },
                ),
              );
            
            },
          
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColor.cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColor.shadowColor.withOpacity(0.08),
              blurRadius: 25,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.secondary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/dog_page1.svg',
                height: 52,
                color: AppColor.secondary,
              ),
            ),
            SizedBox(height: 28),
            Text(
              'Adopt a Pet',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColor.mainColor,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Give a loving home to a pet in need',
              style: TextStyle(
                fontSize: 16,
                color: AppColor.labelColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconCircle(Icons.pets),
                SizedBox(width: 16),
                _buildIconCircle(Icons.favorite),
                SizedBox(width: 16),
                _buildIconCircle(Icons.home),
              ],
            ),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.secondary,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Find Your Pet',
                      style: TextStyle(
                        color: AppColor.cardColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColor.cardColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconCircle(IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.secondary.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColor.secondary, size: 24),
    );
  }
}
