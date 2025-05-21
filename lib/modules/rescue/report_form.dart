import 'dart:convert';
import 'dart:io';
import 'package:adoption_ui_app/modules/rescue/precise_location.dart';
import 'package:flutter/material.dart';
import 'package:adoption_ui_app/theme/color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:adoption_ui_app/config/api_keys.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({Key? key}) : super(key: key);

  @override
  ReportFormState createState() => ReportFormState();
}

class ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final locationController = TextEditingController();
  final String token = const Uuid().v4();

  File? _imageFile;
  String animalType = 'Dog';
  String emergencyType = 'Injured';
  String location = '';
  String description = '';
  String contactNumber = '';
  bool isLoading = false;
  List<dynamic> listOfLocations = [];
  bool _isLoadingLocation = false;
  bool _isAutocompletePaused = false; // Added to control autocomplete requests

  final List<String> animalTypes = ['Dog', 'Cat', 'Bird', 'Other'];
  final List<String> emergencyTypes = [
    'Injured',
    'Trapped',
    'Abandoned',
    'Sick',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    locationController.addListener(() {
      _onLocationChange();
    });
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  void _onLocationChange() {
    // Don't fetch suggestions if autocomplete is paused
    if (locationController.text.isNotEmpty && !_isAutocompletePaused) {
      placeSuggestion(locationController.text);
    } else if (locationController.text.isEmpty) {
      setState(() {
        listOfLocations = [];
      });
    }
  }

  void placeSuggestion(String input) async {
    final String apiKey = APIKeys.googlePlacesAPI;
    try {
      String baseUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request = "$baseUrl?input=$input&key=$apiKey&sessiontoken=$token";
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        setState(() {
          listOfLocations = data['predictions'];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location services are disabled. Please enable the services'),
        backgroundColor: Colors.red,
      ));
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permissions are denied'),
          backgroundColor: Colors.red,
        ));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location permissions are permanently denied'),
        backgroundColor: Colors.red,
      ));
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      final String apiKey = APIKeys.googlePlacesAPI;
      final String url = 
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";
      
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        setState(() {
          // Pause autocomplete to prevent triggering the listener
          _isAutocompletePaused = true;
          locationController.text = data['results'][0]['formatted_address'];
          location = data['results'][0]['formatted_address'];
          _isLoadingLocation = false;
          listOfLocations = [];
        });
        // Resume autocomplete after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            _isAutocompletePaused = false;
          });
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error getting location: $e'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

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

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoading = true;
      });

      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        
        final reportData = {
          'animalType': animalType,
          'emergencyType': emergencyType,
          'location': location,
          'description': description,
          'contactNumber': contactNumber,
          'hasImage': _imageFile != null,
          'status': 'Pending',
          'reportedAt': FieldValue.serverTimestamp(),
          'reportedBy': userId ?? 'anonymous',
        };

        await _firestore.collection('emergencyReports').add(reportData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency reported successfully! Help is on the way.'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
            backgroundColor: Colors.red,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Report Emergency',
          style: TextStyle(
            color: AppColor.mainColor,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF333333)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image picker
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.photo_library, color: AppColor.mainColor),
                                title: Text('Photo Library'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_camera, color: AppColor.mainColor),
                                title: Text('Camera'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _takePhoto();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF000000).withOpacity(0.08),
                          blurRadius: 25,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _imageFile != null
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
                                  color: Color(0xFF3E4249).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 52,
                                  color: AppColor.mainColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Add photo of the animal (optional)',
                                style: TextStyle(
                                  color: Color(0xFF3E4249),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'A photo helps rescuers identify the animal',
                                style: TextStyle(
                                  color: Color(0xFF3E4249).withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Animal Type
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Animal Type',
                    prefixIcon: Icon(
                      Icons.pets,
                      color: Color(0xFF3E4249),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Color(0xFF333333),
                        width: 2,
                      ),
                    ),
                  ),
                  value: animalType,
                  items: animalTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFF333333),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      animalType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Emergency Type
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Emergency Type',
                    prefixIcon: Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFF3E4249),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Color(0xFF333333),
                        width: 2,
                      ),
                    ),
                  ),
                  value: emergencyType,
                  items: emergencyTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Color(0xFF333333),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      emergencyType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Location
                // Replace the existing location TextFormField with this
                Column(
                  children: [
                    TextFormField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location *',
                        hintText: 'Enter address or landmark',
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Color(0xFF3E4249),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.map, color: AppColor.mainColor),
                          onPressed: () {
                            if (locationController.text.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PreciseLocation(
                                    placeName: locationController.text,
                                  ),
                                ),
                              ).then((newLocation) {
                                if (newLocation != null) {
                                  setState(() {
                                    _isAutocompletePaused = true;
                                    locationController.text = newLocation;
                                    location = newLocation;
                                    listOfLocations = [];
                                  });
                                  // Resume autocomplete after a short delay
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    setState(() {
                                      _isAutocompletePaused = false;
                                    });
                                  });
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a location first'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Color(0xFF333333),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter the location'
                          : null,
                      onSaved: (value) => location = value!,
                    ),
                    if (listOfLocations.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: listOfLocations.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Icon(Icons.location_on, color: AppColor.mainColor),
                              title: Text(
                                listOfLocations[index]["description"],
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              onTap: () {
                                // Set the flag to pause autocomplete before updating text
                                setState(() {
                                  _isAutocompletePaused = true;
                                  locationController.text = listOfLocations[index]["description"];
                                  location = listOfLocations[index]["description"];
                                  listOfLocations = [];
                                });
                                
                                // Resume autocomplete after a short delay
                                Future.delayed(const Duration(milliseconds: 300), () {
                                  setState(() {
                                    _isAutocompletePaused = false;
                                  });
                                });
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Contact Number
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contact Number *',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Color(0xFF3E4249),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Color(0xFF333333),
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter your contact number'
                      : null,
                  onSaved: (value) => contactNumber = value!,
                ),
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Brief Description',
                    hintText: 'Describe the emergency situation',
                    prefixIcon: Icon(
                      Icons.description,
                      color: Color(0xFF3E4249),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Color(0xFF333333),
                        width: 2,
                      ),
                    ),
                  ),
                  maxLines: 3,
                  onSaved: (value) => description = value ?? '',
                ),
                const SizedBox(height: 32),
                
                // Submit Button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.secondary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFe96561),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'SUBMIT EMERGENCY REPORT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your report will be sent to nearby animal rescue teams',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF3E4249).withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}