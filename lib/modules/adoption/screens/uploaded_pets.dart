import 'package:adoption_ui_app/main/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'package:adoption_ui_app/modules/adoption/models/pet.dart';
import 'package:adoption_ui_app/modules/adoption/services/pet_service.dart';
import 'package:adoption_ui_app/modules/adoption/screens/pet_details.dart';
import 'package:adoption_ui_app/modules/adoption/screens/upload_pet.dart'; // Import the UploadPet screen

class UploadedPets extends StatefulWidget {
  @override
  _UploadedPetsState createState() => _UploadedPetsState();
}

class _UploadedPetsState extends State<UploadedPets>
    with TickerProviderStateMixin {
  final PetService _petService = PetService();
  int? selectedPetIndex;
  bool _isDisposed = false;
  final List<AnimationController> _heartControllers = [];
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;
  List<Pet> uploadedPets = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late Stream<List<Pet>> _petsStream;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to fetch uploaded pets
    _petsStream = _petService.getUploadedPets();

    // Initialize selection animation controller
    _selectionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    );
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
    for (var controller in _heartControllers) {
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.dispose();
    }
    _heartControllers.clear();

    for (int i = 0; i < uploadedPets.length; i++) {
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
                  !uploadedPets.any(
                    (existingPet) => existingPet.id == newPet.id,
                  ),
            )
            .toList();

    final List<int> removedIndices = [];
    for (int i = 0; i < uploadedPets.length; i++) {
      if (!newPets.any((newPet) => newPet.id == uploadedPets[i].id)) {
        removedIndices.add(i);
      }
    }

    for (int i = removedIndices.length - 1; i >= 0; i--) {
      final int index = removedIndices[i];
      if (_listKey.currentState != null) {
        final petToRemove = uploadedPets[index];
        _listKey.currentState!.removeItem(
          index,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: SlideTransition(
              position: animation.drive(
                Tween(begin: Offset(1.0, 0.0), end: Offset.zero),
              ),
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

        uploadedPets.removeAt(index);
      }
    }

    for (final pet in addedPets) {
      uploadedPets.add(pet);
      _heartControllers.add(
        AnimationController(vsync: this, duration: Duration(milliseconds: 300)),
      );

      if (_listKey.currentState != null) {
        _listKey.currentState!.insertItem(
          uploadedPets.length - 1,
          duration: Duration(milliseconds: 300),
        );
      }
    }

    if (_listKey.currentState == null &&
        (addedPets.isNotEmpty || removedIndices.isNotEmpty)) {
      setState(() {});
    }
  }

  Future<void> _deletePet(int index) async {
    if (_isDisposed || index >= uploadedPets.length || _isDeleting) return;

    try {
      _isDeleting = true;
      await _heartControllers[index].forward();

      if (_isDisposed) return;

      final petToRemove = uploadedPets[index];

      _listKey.currentState?.removeItem(
        index,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: SlideTransition(
            position: animation.drive(
              Tween(begin: Offset(1.0, 0.0), end: Offset.zero),
            ),
            child: _buildPetCard(uploadedPets[index], index),
          ),
        ),
        duration: Duration(milliseconds: 300),
      );

      if (_isDisposed) return;

      setState(() {
        if (index < _heartControllers.length) {
          if (_heartControllers[index].isAnimating) {
            _heartControllers[index].stop();
          }
          _heartControllers[index].dispose();
          _heartControllers.removeAt(index);
        }

        uploadedPets.removeAt(index);

        if (selectedPetIndex == index) {
          selectedPetIndex = null;
          _selectionController.reverse();
        } else if (selectedPetIndex != null && selectedPetIndex! > index) {
          selectedPetIndex = selectedPetIndex! - 1;
        }
      });

      await _petService.deletePet(
        petToRemove.id,
      ); // Add this function in PetService
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

  void _handleTap(int index) {
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

  void _navigateToDetails() {
    if (selectedPetIndex != null && selectedPetIndex! < uploadedPets.length) {
      final selectedPet = uploadedPets[selectedPetIndex!];
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 300),
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  PetDetailsScreen(pet: selectedPet, showContactButton: true),
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
      onTap: () => _handleTap(index),
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
                    onTap: () => _deletePet(index),
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
                            Icons.delete,
                            color: heartColorAnimation.value,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
      body: Column(
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
                        Icon(Icons.pets, color: AppColor.secondary),
                        SizedBox(width: 12),
                        Text(
                          '${uploadedPets.length} Pets Uploaded',
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
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    // Navigate to the UploadPet screen
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration(
                          milliseconds: 300,
                        ), // Duration of animation
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                UploadPet(),
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
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColor.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, color: AppColor.secondary),
                        SizedBox(width: 12),
                        Text(
                          'Add More',
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
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Pet>>(
              stream: _petsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (_isDeleting && uploadedPets.isNotEmpty) {
                  return _buildPetsList();
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    uploadedPets.isEmpty) {
                  return const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasData && !_isDeleting) {
                  final newUploadedPets = snapshot.data ?? [];

                  if (uploadedPets.isEmpty) {
                    uploadedPets = newUploadedPets;
                    _updateAnimationControllers();
                  } else {
                    _updatePetsList(newUploadedPets);
                  }
                }

                if (uploadedPets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 64,
                          color: AppColor.secondary.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No uploaded pets yet',
                          style: TextStyle(
                            color: AppColor.labelColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildPetsList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList() {
    return AnimatedList(
      key: _listKey,
      initialItemCount: uploadedPets.length,
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index, animation) {
        return SlideTransition(
          position: animation.drive(
            Tween(begin: Offset(1.0, 0.0), end: Offset.zero),
          ),
          child: _buildPetCard(uploadedPets[index], index),
        );
      },
    );
  }
}
