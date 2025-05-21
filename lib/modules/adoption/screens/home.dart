import 'package:adoption_ui_app/modules/adoption/utils/data.dart';
import 'package:adoption_ui_app/main/widgets/custom_app_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'package:adoption_ui_app/modules/adoption/models/pet.dart';
import 'package:adoption_ui_app/modules/adoption/services/pet_service.dart';
import 'package:adoption_ui_app/modules/adoption/widgets/category_item.dart';
import 'package:adoption_ui_app/modules/adoption/widgets/pet_item.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PetService _petService = PetService();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize FirebaseAuth
  List<Pet> _pets = [];
  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: CustomAppBar(showBackButton: true),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildBody(),
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            _buildCategories(),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 25),
              child: Text(
                "Adopt Me",
                style: TextStyle(
                  color: AppColor.textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ),
            _buildPets(),
          ],
        ),
      ),
    );
  }

  _buildCategories() {
    List<Widget> lists = List.generate(
      categories.length,
      (index) => CategoryItem(
        data: categories[index],
        selected: index == _selectedCategory,
        onTap: () {
          setState(() {
            _selectedCategory = index;
          });
        },
      ),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(bottom: 5, left: 15),
      child: Row(children: lists),
    );
  }

  Widget _buildPets() {
    return StreamBuilder<List<Pet>>(
      stream: _petService.getPets(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter pets based on selected category
        _pets = snapshot.data ?? [];
        List<Pet> filteredPets = _selectedCategory == 0 
            ? _pets  // Show all pets if "All" category (index 0) is selected
            : _pets.where((pet) => 
                pet.category.toLowerCase() == categories[_selectedCategory]['name'].toLowerCase()
              ).toList();

        if (filteredPets.isEmpty) {
          return const Center(child: Text('No pets available in this category'));
        }

        double width = MediaQuery.of(context).size.width * .8;
        return CarouselSlider(
          options: CarouselOptions(
            height: 400,
            enlargeCenterPage: true,
            disableCenter: true,
            viewportFraction: .8,
          ),
          items: filteredPets.map((pet) {
            String currentUserId = _auth.currentUser?.uid ?? '';
            return PetItem(
              data: pet,
              userId: currentUserId,
              width: width,
              onTap: () {
                // Handle pet item tap
              },
              onFavoriteTap: () async {
                await _petService.updatePetFavoriteStatus(
                  pet,
                  currentUserId,
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
