import 'package:adoption_ui_app/modules/adoption/screens/pre_upload_pet.dart';
import 'package:adoption_ui_app/modules/adoption/screens/uploaded_pets.dart';
import 'package:flutter/material.dart';
import 'package:adoption_ui_app/modules/adoption/screens/home.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'package:adoption_ui_app/modules/adoption/utils/constant.dart';
import 'package:adoption_ui_app/modules/adoption/widgets/bottombar_item.dart';
import 'package:adoption_ui_app/modules/adoption/screens/liked_pets.dart';
import 'package:adoption_ui_app/modules/adoption/services/pet_service.dart';

class RootApp extends StatefulWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> with TickerProviderStateMixin {
  int _activeTab = 0;
  final PetService _petService = PetService();
  bool _hasUploadedPets = false; // Track if the user has uploaded pets

  final List barItems = [
    {
      "icon": Icons.home_outlined,
      "active_icon": Icons.home,
      "page": HomePage(),
    },
    {
      "icon": Icons.pets_outlined,
      "active_icon": Icons.pets,
      "page": LikedPets(),
    },
    {
      "icon": Icons.add_outlined,
      "active_icon": Icons.add,
      "page": PreUploadPage(),
    },
  ];

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: ANIMATED_BODY_MS),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _checkForUploadedPets(); // Check if the user has uploaded any pets
  }

  // Check if the current user has uploaded any pets
  Future<void> _checkForUploadedPets() async {
    try {
      final hasUploads = await _petService.checkUserHasUploadedPets();
      setState(() {
        _hasUploadedPets = hasUploads;
      });
    } catch (e) {
      debugPrint('Error checking for uploaded pets: $e');
    }
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  _buildAnimatedPage(page) {
    return FadeTransition(child: page, opacity: _animation);
  }

  // Handle page changes
  void onPageChanged(int index) async {
    if (index == 3) {
      // Check if navigating to the upload/settings tab
      await _checkForUploadedPets(); // Refresh pet status
    }

    _controller.reset();
    setState(() {
      _activeTab = index;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      body: _buildPage(),
      floatingActionButton: _buildBottomBar(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }

  Widget _buildPage() {
    return IndexedStack(
      index: _activeTab,
      children: List.generate(barItems.length, (index) {
        if (index == 3) {
          // For the upload/settings tab
          return _buildAnimatedPage(
            _hasUploadedPets
                ? UploadedPets()
                : PreUploadPage(), // Show appropriate page based on upload status
          );
        }
        return _buildAnimatedPage(barItems[index]["page"]);
      }),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 55,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
      decoration: BoxDecoration(
        color: AppColor.bottomBarColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.shadowColor.withOpacity(0.1),
            blurRadius: 1,
            spreadRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          barItems.length,
          (index) => BottomBarItem(
            Icon(_activeTab == index
                ? barItems[index]["active_icon"]
                : barItems[index]["icon"]),
            isActive: _activeTab == index,
            activeColor: AppColor.primary,
            onTap: () => onPageChanged(index),
          ),
        ),
      ),
    );
  }
}
