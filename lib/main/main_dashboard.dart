import 'package:adoption_ui_app/main/mediator/page1.dart';
import 'package:adoption_ui_app/main/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'mediator/page2.dart';
import 'mediator/page3.dart';

class MainDashboard extends StatefulWidget {
  @override
  MainDashboardState createState() => MainDashboardState();
}

class MainDashboardState extends State<MainDashboard> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackButton: false),
      backgroundColor: AppColor.appBgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.cardColor, AppColor.appBgColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.appBgColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: PageView(
                    controller: _pageController,
                    children: [Page1(), Page2(), Page3()],
                  ),
                ),
              ),
              _buildPageIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20), // Adjust bottom padding as needed
      child: SmoothPageIndicator(
        controller: _pageController,
        count: 3,
        effect: ExpandingDotsEffect(
          activeDotColor: AppColor.secondary,
          dotColor: AppColor.inActiveColor.withOpacity(0.5),
          dotHeight: 14, // Increased dot size
          dotWidth: 14, // Increased dot size
          spacing: 10, // Adjusted spacing for better look
          expansionFactor: 3,
        ),
      ),
    );
  }
}
