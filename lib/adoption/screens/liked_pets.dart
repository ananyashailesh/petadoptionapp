import 'package:adoption_ui_app/main/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'package:adoption_ui_app/adoption/models/pet.dart';
import 'package:adoption_ui_app/adoption/services/pet_service.dart';
import 'package:adoption_ui_app/adoption/screens/pet_details.dart';

class LikedPets extends StatefulWidget {
  @override
  _LikedPetsState createState() => _LikedPetsState();
}

class _LikedPetsState extends State<LikedPets> with TickerProviderStateMixin {
  final PetService _petService = PetService();
  int? selectedPetIndex;
  bool _isDisposed = false;
  final List<AnimationController> _heartControllers = [];
  // Add selection animation controller
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;
  List<Pet> likedPets = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Add this to cache the stream data
  late Stream<List<Pet>> _petsStream;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Initialize the stream once
    _petsStream = _petService.getLikedPets();

    // Initialize selection animation controller
    _selectionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    );
    _petService.onPetDeleted.listen((petId) {
      _removePetById(petId); // Remove the pet from the list
    });
  }

  void _removePetById(String petId) {
    final index = likedPets.indexWhere((pet) => pet.id == petId);
    if (index != -1) {
      _unlikePet(
        index,
      ); // Call the existing _unlikePet method to remove the pet
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (var controller in _heartControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.dispose();
    }
    _heartControllers.clear();
    _selectionController.dispose();
    super.dispose();
  }

  void _updateAnimationControllers() {
    // Dispose existing controllers
    for (var controller in _heartControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.dispose();
    }
    _heartControllers.clear();

    // Create new controllers for current pets
    for (int i = 0; i < likedPets.length; i++) {
      _heartControllers.add(
        AnimationController(vsync: this, duration: Duration(milliseconds: 300)),
      );
    }
  }

  void _updatePetsList(List<Pet> newPets) {
    final List<Pet> addedPets =
        newPets
            .where(
              (newPet) =>
                  !likedPets.any((existingPet) => existingPet.id == newPet.id),
            )
            .toList();

    final List<int> removedIndices = [];
    for (int i = 0; i < likedPets.length; i++) {
      if (!newPets.any((newPet) => newPet.id == likedPets[i].id)) {
        removedIndices.add(i);
      }
    }

    for (int i = removedIndices.length - 1; i >= 0; i--) {
      final int index = removedIndices[i];
      if (_listKey.currentState != null) {
        final petToRemove = likedPets[index];
        _listKey.currentState!.removeItem(
          index,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: FadeTransition(
              opacity: animation, // Fade out the deleted pet
              child: _buildPetCard(petToRemove, index),
            ),
          ),
          duration: Duration(milliseconds: 300),
        );

        if (index < _heartControllers.length) {
          if (_heartControllers[index].isAnimating) {
            _heartControllers[index].stop();
          }
          _heartControllers[index].dispose();
          _heartControllers.removeAt(index);
        }
        likedPets.removeAt(index);
      }
    }

    for (final pet in addedPets) {
      likedPets.add(pet);
      _heartControllers.add(
        AnimationController(vsync: this, duration: Duration(milliseconds: 300)),
      );
      if (_listKey.currentState != null) {
        _listKey.currentState!.insertItem(
          likedPets.length - 1,
          duration: Duration(milliseconds: 300),
        );
      }
    }

    if (_listKey.currentState == null &&
        (addedPets.isNotEmpty || removedIndices.isNotEmpty)) {
      setState(() {});
    }
  }

  Future<void> _unlikePet(int index) async {
    if (_isDisposed || index < 0 || index >= likedPets.length || _isDeleting)
      return;

    try {
      _isDeleting = true;

      // Capture the pet to remove before any modifications
      final petToRemove = likedPets[index];

      // Ensure the heart controller exists and animate it
      if (index < _heartControllers.length) {
        await _heartControllers[index].forward();
      }

      if (_isDisposed) return;

      // Remove the item from the animated list with fade-out animation
      if (_listKey.currentState != null) {
        _listKey.currentState!.removeItem(
          index,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: FadeTransition(
              opacity: animation, // Fade out the deleted pet
              child: _buildPetCard(petToRemove, index),
            ),
          ),
          duration: Duration(milliseconds: 300),
        );
      }

      if (_isDisposed) return;

      // Update state atomically
      setState(() {
        if (index < _heartControllers.length) {
          if (_heartControllers[index].isAnimating) {
            _heartControllers[index].stop();
          }
          _heartControllers[index].dispose();
          _heartControllers.removeAt(index);
        }
        likedPets.removeAt(index);
        if (selectedPetIndex == index) {
          selectedPetIndex = null;
          _selectionController.reverse();
        } else if (selectedPetIndex != null && selectedPetIndex! > index) {
          selectedPetIndex = selectedPetIndex! - 1;
        }
      });

      // Remove from Firebase
      await _petService.removeLikedPet(petToRemove.id);
    } catch (e) {
      debugPrint('Error during pet removal: $e');
    } finally {
      if (!_isDisposed) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _handleLongPress(int index) {
    if (_isDisposed) return;
    setState(() {
      if (selectedPetIndex == index) {
        selectedPetIndex = null;
        _selectionController.reverse();
      } else {
        selectedPetIndex = index;
        _selectionController.forward(from: 0.0);
      }
    });
  }

  // New method to handle tap on a pet
  void _handleTap(int index) {
    if (_isDisposed) return;
    setState(() {
      // If this pet is already selected, deselect it
      if (selectedPetIndex == index) {
        selectedPetIndex = null;
        _selectionController.reverse();
      } else {
        // Otherwise select this pet (deselecting any previous one)
        selectedPetIndex = index;
        _selectionController.forward(from: 0.0);
      }
    });
  }

  // Navigate to pet details screen with slide up animation
  void _navigateToDetails() {
    if (selectedPetIndex != null && selectedPetIndex! < likedPets.length) {
      final selectedPet = likedPets[selectedPetIndex!];
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder:
              (context, animation, secondaryAnimation) => PetDetailsScreen(
                pet: selectedPet,
                showContactButton: false,
              ), // Pass the selected pet
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 1),
                end: Offset(0, 0),
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  Widget _buildPetCard(Pet pet, int index) {
    if (index >= _heartControllers.length) {
      return SizedBox.shrink();
    }

    final heartColorAnimation = ColorTween(
      begin: AppColor.secondary,
      end: Colors.transparent,
    ).animate(_heartControllers[index]);

    final heartBackgroundAnimation = ColorTween(
      begin: AppColor.secondary.withOpacity(0.15),
      end: Colors.transparent,
    ).animate(_heartControllers[index]);

    return GestureDetector(
      onLongPress: () => _handleLongPress(index),
      onTap: () => _handleTap(index), // Add tap handling
      child: AnimatedBuilder(
        animation: _selectionAnimation,
        builder: (context, child) {
          final borderWidth =
              selectedPetIndex == index ? 2.0 * _selectionAnimation.value : 0.0;
          final borderColor =
              selectedPetIndex == index
                  ? AppColor.secondary.withOpacity(_selectionAnimation.value)
                  : Colors.transparent;

          return Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColor.cardColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColor.shadowColor.withOpacity(0.08),
                  blurRadius: 25,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                      child: Image.network(
                        pet.image,
                        width: 120,
                        height: 140,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          // Return a placeholder instead of loading indicator
                          return Container(
                            width: 120,
                            height: 140,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.pets,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 140,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pet.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColor.mainColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              pet.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.labelColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: AppColor.secondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  pet.age,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.labelColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppColor.secondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  pet.location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.labelColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () => _unlikePet(index),
                    child: AnimatedBuilder(
                      animation: _heartControllers[index],
                      builder: (context, child) {
                        return Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: heartBackgroundAnimation.value,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: heartColorAnimation.value,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Subtle highlight overlay when selected
                if (selectedPetIndex == index)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: AnimatedBuilder(
                        animation: _selectionAnimation,
                        builder: (context, child) {
                          return Container(
                            color: AppColor.secondary.withOpacity(
                              0.05 * _selectionAnimation.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: CustomAppBar(showBackButton: true),
      // Add animated FloatingActionButton for navigation when a pet is selected
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          selectedPetIndex != null
              ? Padding(
                padding: EdgeInsets.only(
                  bottom: 80,
                ), // Adjust this value based on your bottom nav height
                child: FloatingActionButton.extended(
                  onPressed: _navigateToDetails,
                  label: Text(
                    'View Details',
                    style: TextStyle(color: Colors.white),
                  ),
                  icon: Icon(Icons.pets, color: Colors.white),
                  backgroundColor: AppColor.secondary,
                ),
              )
              : null,
      body: StreamBuilder<List<Pet>>(
        stream: _petsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Return previously cached data during deletion to prevent loading indicator
          if (_isDeleting && likedPets.isNotEmpty) {
            // Continue using current likedPets list during deletion
            return _buildPetsList();
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              likedPets.isEmpty) {
            // Only show loading on initial load, not during updates
            return const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Handle data updates from the stream
          if (snapshot.hasData && !_isDeleting) {
            final newLikedPets = snapshot.data ?? [];

            // If we're seeing this data for the first time, initialize everything
            if (likedPets.isEmpty) {
              likedPets = newLikedPets;
              _updateAnimationControllers();
            } else {
              // Handle updates to the list - compare old and new lists
              _updatePetsList(newLikedPets);
            }
          }

          if (likedPets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppColor.secondary.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorite pets yet',
                    style: TextStyle(color: AppColor.labelColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return _buildPetsList();
        },
      ),
    );
  }

  // Extract list building to separate method
  Widget _buildPetsList() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: AppColor.secondary),
                      SizedBox(width: 12),
                      Text(
                        '${likedPets.length} Pets Liked',
                        style: TextStyle(
                          color: AppColor.secondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Animated selection indicator
              AnimatedBuilder(
                animation: _selectionAnimation,
                builder: (context, child) {
                  return selectedPetIndex != null
                      ? Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Transform.scale(
                          scale: _selectionAnimation.value,
                          child: Opacity(
                            opacity: _selectionAnimation.value,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.secondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Selected',
                                style: TextStyle(
                                  color: AppColor.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      : SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedList(
            key: _listKey,
            initialItemCount: likedPets.length,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index, animation) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: Offset(1.0, 0.0), end: Offset.zero),
                ),
                child: _buildPetCard(likedPets[index], index),
              );
            },
          ),
        ),
      ],
    );
  }
}
