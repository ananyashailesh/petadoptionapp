import 'dart:io';
import 'package:adoption_ui_app/modules/adoption/screens/uploaded_pets.dart';
import 'package:adoption_ui_app/modules/adoption/services/drive_service.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UploadPet extends StatefulWidget {
  const UploadPet({Key? key}) : super(key: key);

  @override
  UploadPetState createState() => UploadPetState();
}

class UploadPetState extends State<UploadPet> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String name = '';
  String category = 'Dog';
  String location = '';
  String color = '';
  double price = 0.0;
  String sex = 'Male';
  String age = '';
  String description = '';
  double weight = 0.0;
  String breed = '';
  bool isVaccinated = false;
  bool isNeutered = false;
  String healthStatus = 'Healthy';
  String temperament = 'Friendly';
  List<String> specialNeeds = [];
  String energyLevel = 'Medium';
  bool isHouseTrained = false;
  String dietaryNeeds = '';

  bool isLoading = false;
  int _currentStep = 0;

  final List<String> categories = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  final List<String> sexOptions = ['Male', 'Female'];
  final List<String> healthStatusOptions = [
    'Healthy',
    'Under Treatment',
    'Special Care Required',
    'Recovering',
  ];
  final List<String> temperamentOptions = [
    'Friendly',
    'Shy',
    'Active',
    'Calm',
    'Independent',
  ];
  final List<String> energyLevelOptions = ['Low', 'Medium', 'High'];
  final List<String> specialNeedsOptions = [
    'Medical Care',
    'Special Diet',
    'Behavioral Training',
    'Physical Disability',
    'Senior Care',
  ];

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPet() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: AppColor.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      String imageUrl = '';

      try {
        final filename =
            '${name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final driveService = GoogleDriveService();
        final driveImageUrl = await driveService.uploadFile(
          _imageFile!,
          filename,
        );

        if (driveImageUrl == null) {
          throw Exception('Failed to upload image to Google Drive');
        }

        imageUrl = driveImageUrl;

        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        final petData = {
          'name': name,
          'image': imageUrl,
          'category': category,
          'location': location,
          'color': color,
          'price': price,
          'sex': sex,
          'age': age,
          'description': description,
          'weight': weight,
          'breed': breed,
          'isVaccinated': isVaccinated,
          'isNeutered': isNeutered,
          'healthStatus': healthStatus,
          'temperament': temperament,
          'specialNeeds': specialNeeds,
          'energyLevel': energyLevel,
          'isHouseTrained': isHouseTrained,
          'dietaryNeeds': dietaryNeeds,
          'isFavorited': false,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'userId': userId,
        };

        final DocumentReference docRef = await _firestore
            .collection('pets')
            .add(petData);
        final DocumentSnapshot doc = await docRef.get();
        if (!doc.exists) {
          throw Exception('Failed to verify document creation');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Pet added successfully!')),
        );

        await Future.delayed(const Duration(seconds: 2));

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => UploadedPets(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );

        _formKey.currentState!.reset();
        setState(() {
          _imageFile = null;
          specialNeeds = [];
          isVaccinated = false;
          isNeutered = false;
          isHouseTrained = false;
          _currentStep = 0;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding pet: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      appBar: AppBar(
        title: const Text(
          'Add A Pet',
          style: TextStyle(
            color: AppColor.mainColor,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white, // AppBar background color
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF333333)), // Back button color
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Theme(
            data: ThemeData(
              colorScheme: ColorScheme.light(
                primary: Color(0xFFe96561), // Stepper active color (red)
              ),
              indicatorColor: Color(
                0xFFe96561,
              ), // Stepper indicator color (red)
              unselectedWidgetColor: Color(
                0xFFe96561,
              ).withOpacity(0.5), // Stepper inactive color (red with opacity)
            ),
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() {
                    _currentStep += 1;
                  });
                } else {
                  _submitPet();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                }
              },
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _currentStep < 3
                                ? details.onStepContinue
                                : (isLoading ? null : _submitPet),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(
                            0xFFe96561,
                          ), // Button background color (red)
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child:
                            _currentStep < 3
                                ? const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white, // Button text color
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color:
                                        Colors.white, // Loading indicator color
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.white, // Button text color
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: Color(0xFFe96561), // Border color (red)
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: Color(0xFFe96561), // Text color (red)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
              physics: const ClampingScrollPhysics(),
              steps: [
                // Step 1: Pet Image and Basic Info
                Step(
                  title: Text(
                    'Basic Information',
                    style: TextStyle(
                      color: Color(0xFF333333), // Step title color
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white, // Container background color
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(
                                  0xFF000000,
                                ).withOpacity(0.08), // Shadow color
                                blurRadius: 25,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child:
                              _imageFile != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF3E4249).withOpacity(
                                            0.15,
                                          ), // Icon background color
                                          shape: BoxShape.circle,
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/icons/dog_page1.svg',
                                          height: 52,
                                          color: Color(
                                            0xFFe96561,
                                          ), // Icon color
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tap to upload pet photo',
                                        style: TextStyle(
                                          color: Color(
                                            0xFF3E4249,
                                          ), // Text color
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'A good photo helps adoption!',
                                        style: TextStyle(
                                          color: Color(
                                            0xFF3E4249,
                                          ).withOpacity(0.6), // Subtext color
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Pet Name',
                          prefixIcon: Icon(
                            Icons.pets,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Please enter pet name'
                                    : null,
                        onSaved: (value) => name = value!,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(
                            Icons.category,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        value: category,
                        items:
                            categories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                  ), // Dropdown text color
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            category = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Breed',
                          prefixIcon: Icon(
                            Icons.cruelty_free,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        onSaved: (value) => breed = value ?? '',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Sex',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        value: sex,
                        items:
                            sexOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                  ), // Dropdown text color
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            sex = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  isActive: _currentStep == 0,
                ),

                // Step 2: Physical Characteristics
                Step(
                  title: Text(
                    'Physical Characteristics',
                    style: TextStyle(
                      color: Color(0xFF333333), // Step title color
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Age',
                          hintText: 'e.g., 2 years, 6 months',
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        onSaved: (value) => age = value ?? '',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          hintText: 'e.g., 5.2',
                          prefixIcon: Icon(
                            Icons.fitness_center,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSaved:
                            (value) =>
                                weight = double.tryParse(value ?? '') ?? 0.0,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Color',
                          hintText: 'e.g., Black & White, Tabby',
                          prefixIcon: Icon(
                            Icons.color_lens,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        onSaved: (value) => color = value ?? '',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Energy Level',
                          prefixIcon: Icon(
                            Icons.bolt,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        value: energyLevel,
                        items:
                            energyLevelOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                  ), // Dropdown text color
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            energyLevel = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Temperament',
                          prefixIcon: Icon(
                            Icons.psychology,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        value: temperament,
                        items:
                            temperamentOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                  ), // Dropdown text color
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            temperament = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  isActive: _currentStep == 1,
                ),

                // Step 3: Health Information
                Step(
                  title: Text(
                    'Health Information',
                    style: TextStyle(
                      color: Color(0xFF333333), // Step title color
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Health Status',
                          prefixIcon: Icon(
                            Icons.favorite,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        value: healthStatus,
                        items:
                            healthStatusOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: Color(0xFF333333),
                                  ), // Dropdown text color
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            healthStatus = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      Card(
                        elevation: 0,
                        color: Colors.white, // Card background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Color(0xFF3E4249).withOpacity(0.2),
                          ), // Border color
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text(
                                'Vaccinated',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                ), // Text color
                              ),
                              subtitle: Text(
                                'Has this pet received required vaccinations?',
                                style: TextStyle(
                                  color: Color(0xFF3E4249).withOpacity(0.6),
                                ), // Subtext color
                              ),
                              value: isVaccinated,
                              activeColor: Color(
                                0xFF333333,
                              ), // Switch active color
                              onChanged: (bool? value) {
                                setState(() {
                                  isVaccinated = value ?? false;
                                });
                              },
                            ),
                            Divider(
                              color: Color(0xFF3E4249).withOpacity(0.2),
                              height: 1,
                            ),
                            SwitchListTile(
                              title: Text(
                                'Neutered/Spayed',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                ), // Text color
                              ),
                              subtitle: Text(
                                'Has this pet been neutered or spayed?',
                                style: TextStyle(
                                  color: Color(0xFF3E4249).withOpacity(0.6),
                                ), // Subtext color
                              ),
                              value: isNeutered,
                              activeColor: Color(
                                0xFF333333,
                              ), // Switch active color
                              onChanged: (bool? value) {
                                setState(() {
                                  isNeutered = value ?? false;
                                });
                              },
                            ),
                            Divider(
                              color: Color(0xFF3E4249).withOpacity(0.2),
                              height: 1,
                            ),
                            SwitchListTile(
                              title: Text(
                                'House Trained',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                ), // Text color
                              ),
                              subtitle: Text(
                                'Is this pet house trained?',
                                style: TextStyle(
                                  color: Color(0xFF3E4249).withOpacity(0.6),
                                ), // Subtext color
                              ),
                              value: isHouseTrained,
                              activeColor: Color(
                                0xFF333333,
                              ), // Switch active color
                              onChanged: (bool? value) {
                                setState(() {
                                  isHouseTrained = value ?? false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Special Needs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333), // Text color
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children:
                            specialNeedsOptions.map((String need) {
                              final isSelected = specialNeeds.contains(need);
                              return FilterChip(
                                label: Text(
                                  need,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Color(0xFF333333), // Text color
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: Color(
                                  0xFF333333,
                                ), // Selected chip color
                                checkmarkColor: Colors.white, // Checkmark color
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      specialNeeds.add(need);
                                    } else {
                                      specialNeeds.remove(need);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Dietary Needs',
                          hintText: 'Enter any special dietary requirements...',
                          prefixIcon: Icon(
                            Icons.restaurant_menu,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 3,
                        onSaved: (value) => dietaryNeeds = value ?? '',
                      ),
                    ],
                  ),
                  isActive: _currentStep == 2,
                ),

                // Step 4: Additional Information
                Step(
                  title: Text(
                    'Final Details',
                    style: TextStyle(
                      color: Color(0xFF333333), // Step title color
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Location',
                          hintText: 'City or neighborhood where pet is located',
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        onSaved: (value) => location = value ?? '',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Adoption Fee',
                          hintText: 'Enter 0 if free',
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSaved:
                            (value) =>
                                price = double.tryParse(value ?? '') ?? 0.0,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText:
                              'Share more details about the pet\'s personality, background, etc.',
                          prefixIcon: Icon(
                            Icons.description,
                            color: Color(0xFF3E4249),
                          ), // Icon color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Color(0xFF333333), // Focus border color
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 5,
                        onSaved: (value) => description = value ?? '',
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                  isActive: _currentStep == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
