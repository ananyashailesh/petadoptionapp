class Pet {
  final String id;
  final String name;
  final String image;
  final String category;
  final String location;
  final String color;
  final double price;
  final String sex;
  final String age;
  final String description;
  final double weight;
  final String breed;
  final String dietaryNeeds;
  final String energyLevel;
  final String healthStatus;
  final bool isHouseTrained;
  final bool isNeutered;
  final bool isVaccinated;
  final List<String> specialNeeds;
  final String temperament;
  final String petId;
  final String userId;
  List<String> favoritedBy; // List of user IDs who favorited the pet

  Pet({
    required this.id,
    required this.name,
    required this.image,
    required this.category,
    required this.location,
    required this.color,
    required this.price,
    required this.sex,
    required this.age,
    required this.description,
    required this.weight,
    required this.breed,
    required this.dietaryNeeds,
    required this.energyLevel,
    required this.healthStatus,
    required this.isHouseTrained,
    required this.isNeutered,
    required this.isVaccinated,
    required this.specialNeeds,
    required this.temperament,
    required this.petId,
    required this.userId,
    this.favoritedBy = const [], // Initialize as empty list
  });

  factory Pet.fromFirestore(Map<String, dynamic> doc, String id) {
    return Pet(
      id: id,
      name: doc['name'] ?? '',
      image: doc['image'] ?? '',
      category: doc['category'] ?? '',
      location: doc['location'] ?? '',
      color: doc['color'] ?? '',
      price: (doc['price'] ?? 0).toDouble(),
      sex: doc['sex'] ?? '',
      age: doc['age'] ?? '',
      description: doc['description'] ?? '',
      weight: (doc['weight'] ?? 0).toDouble(),
      breed: doc['breed'] ?? '',
      dietaryNeeds: doc['dietaryNeeds'] ?? '',
      energyLevel: doc['energyLevel'] ?? '',
      healthStatus: doc['healthStatus'] ?? '',
      isHouseTrained: doc['isHouseTrained'] ?? false,
      isNeutered: doc['isNeutered'] ?? false,
      isVaccinated: doc['isVaccinated'] ?? false,
      specialNeeds: List<String>.from(doc['specialNeeds'] ?? []),
      temperament: doc['temperament'] ?? '',
      favoritedBy: List<String>.from(
        doc['favoritedBy'] ?? [],
      ), // Initialize from Firestore
      petId: doc['petId'] ?? '',
      userId: doc['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'category': category,
      'location': location,
      'color': color,
      'price': price,
      'sex': sex,
      'age': age,
      'description': description,
      'weight': weight,
      'breed': breed,
      'dietaryNeeds': dietaryNeeds,
      'energyLevel': energyLevel,
      'healthStatus': healthStatus,
      'isHouseTrained': isHouseTrained,
      'isNeutered': isNeutered,
      'isVaccinated': isVaccinated,
      'specialNeeds': specialNeeds,
      'temperament': temperament,
      'favoritedBy': favoritedBy, // Include favoritedBy in the map
      'petId': petId,
      'userId': userId,
    };
  }
}
