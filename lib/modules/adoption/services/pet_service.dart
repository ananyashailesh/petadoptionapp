import 'package:adoption_ui_app/modules/adoption/models/pet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // Import for StreamController

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // StreamController to broadcast pet deletion events
  final StreamController<String> _petDeletedController = StreamController<String>.broadcast();

  // Expose the stream for listening to pet deletion events
  Stream<String> get onPetDeleted => _petDeletedController.stream;

  // Get all pets excluding those uploaded by the current user
  Stream<List<Pet>> getPets() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('pets')
        .where('userId', isNotEqualTo: userId) // Exclude pets uploaded by the current user
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Pet.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Get liked pets for the current user
  Stream<List<Pet>> getLikedPets() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('pets')
        .where('favoritedBy', arrayContains: userId) // Filter pets favorited by the current user
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Pet.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Update pet favorite status for the current user
  Future<void> updatePetFavoriteStatus(Pet pet, String userId) async {
    final petRef = _firestore.collection('pets').doc(pet.id);

    if (pet.favoritedBy.contains(userId)) {
      // If the user has already favorited the pet, remove them from the list
      await petRef.update({
        'favoritedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      // If the user hasn't favorited the pet, add them to the list
      await petRef.update({
        'favoritedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // Remove liked pet for the current user
  Future<void> removeLikedPet(String petId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Remove the user from the favoritedBy list in the main pets collection
    await _firestore.collection('pets').doc(petId).update({
      'favoritedBy': FieldValue.arrayRemove([userId]),
    });
  }

  // Check if the current user has uploaded any pets
  Future<bool> checkUserHasUploadedPets() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final snapshot =
        await _firestore
            .collection('pets')
            .where('userId', isEqualTo: userId) // Filter by userId
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get uploaded pets for the current user
  Stream<List<Pet>> getUploadedPets() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('pets')
        .where('userId', isEqualTo: userId) // Filter by userId
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Pet.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Delete a pet and broadcast the deletion event
  Future<void> deletePet(String petId) async {
    // Delete the pet from the main pets collection
    await _firestore.collection('pets').doc(petId).delete();

    // Broadcast the pet deletion event
    _petDeletedController.add(petId);
  }

  // Dispose the StreamController when no longer needed
  void dispose() {
    _petDeletedController.close();
  }


}