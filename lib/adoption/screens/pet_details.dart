import 'package:adoption_ui_app/main/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:adoption_ui_app/adoption/models/pet.dart';
import 'package:adoption_ui_app/theme/color.dart';

class PetDetailsScreen extends StatelessWidget {
  final Pet pet;
  final bool showContactButton; // Replaced id with showContactButton

  const PetDetailsScreen({
    Key? key,
    required this.pet,
    required this.showContactButton, // Require showContactButton in constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBgColor,
      appBar: CustomAppBar(showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Container(
              height: 300,
              width: double.infinity,
              child: Image.network(
                pet.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    pet.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainColor,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Category and Age
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pet.category,
                          style: TextStyle(
                            color: AppColor.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pet.age,
                          style: TextStyle(
                            color: AppColor.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Price
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Adoption Fee: \$${pet.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Breed
                  Row(
                    children: [
                      Icon(Icons.pets, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Breed: ${pet.breed}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Weight
                  Row(
                    children: [
                      Icon(Icons.fitness_center, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Weight: ${pet.weight} kg',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Location: ${pet.location}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Sex
                  Row(
                    children: [
                      Icon(Icons.people, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Sex: ${pet.sex}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Color
                  Row(
                    children: [
                      Icon(Icons.color_lens, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Color: ${pet.color}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Health Status
                  Row(
                    children: [
                      Icon(Icons.health_and_safety, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Health Status: ${pet.healthStatus}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Energy Level
                  Row(
                    children: [
                      Icon(Icons.bolt, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Energy Level: ${pet.energyLevel}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Temperament
                  Row(
                    children: [
                      Icon(Icons.psychology, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Temperament: ${pet.temperament}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Dietary Needs
                  Row(
                    children: [
                      Icon(Icons.restaurant, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Dietary Needs: ${pet.dietaryNeeds}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Special Needs
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            color: AppColor.secondary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Special Needs:',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.labelColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            pet.specialNeeds
                                .map(
                                  (need) => Chip(
                                    label: Text(need),
                                    backgroundColor: AppColor.secondary
                                        .withOpacity(0.2),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Vaccination Status
                  Row(
                    children: [
                      Icon(Icons.medical_services, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Vaccinated: ${pet.isVaccinated ? 'Yes' : 'No'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Neutered Status
                  Row(
                    children: [
                      Icon(Icons.pets, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'Neutered/Spayed: ${pet.isNeutered ? 'Yes' : 'No'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // House Trained Status
                  Row(
                    children: [
                      Icon(Icons.home, color: AppColor.secondary),
                      SizedBox(width: 8),
                      Text(
                        'House Trained: ${pet.isHouseTrained ? 'Yes' : 'No'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColor.labelColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Description
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColor.mainColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    pet.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColor.labelColor,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Show button based on showContactButton
                  if (!showContactButton)
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Contact initiated with owner for ${pet.name}',
                            ),
                            backgroundColor: AppColor.secondary,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.secondary,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Contact About ${pet.name}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
