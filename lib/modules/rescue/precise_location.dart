import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:adoption_ui_app/config/api_keys.dart';

class PreciseLocation extends StatefulWidget {
  final String placeName;
  
  const PreciseLocation({
    Key? key,
    required this.placeName,
  }) : super(key: key);

  @override
  State<PreciseLocation> createState() => _PreciseLocationState();
}

class _PreciseLocationState extends State<PreciseLocation> {
  GoogleMapController? _mapController;
  LatLng? _placeLocation;
  bool _isLoading = true;
  String _errorMessage = '';
  Set<Marker> _markers = {};
  LatLng? _currentMarkerPosition;
  String _currentAddress = '';

  @override
  void initState() {
    super.initState();
    _getPlaceCoordinates();
  }

  Future<void> _getPlaceCoordinates() async {
    try {
      final String apiKey = APIKeys.googlePlacesAPI;
      final String encodedPlace = Uri.encodeComponent(widget.placeName);
      final String url = 
          "https://maps.googleapis.com/maps/api/geocode/json?address=$encodedPlace&key=$apiKey";
      
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final double lat = location['lat'];
        final double lng = location['lng'];
        
        setState(() {
          _placeLocation = LatLng(lat, lng);
          _currentMarkerPosition = _placeLocation;
          _currentAddress = data['results'][0]['formatted_address'];
          _isLoading = false;
          _updateMarker();
        });
        
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _placeLocation!,
                zoom: 15,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not find coordinates for this place';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<String?> _getAddressFromLatLng(LatLng position) async {
    try {
      final String apiKey = APIKeys.googlePlacesAPI;
      final String url = 
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";
      
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting address: $e');
      }
    }
    return null;
  }

  void _updateMarker() {
    if (_currentMarkerPosition != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('selected_place'),
            position: _currentMarkerPosition!,
            draggable: true,
            onDragEnd: (LatLng newPosition) async {
              setState(() {
                _currentMarkerPosition = newPosition;
              });
              
              final newAddress = await _getAddressFromLatLng(newPosition);
              if (newAddress != null) {
                setState(() {
                  _currentAddress = newAddress;
                });
              }
            },
          ),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Adjust Location',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 70,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _placeLocation ?? const LatLng(0, 0),
                        zoom: 15,
                      ),
                      markers: _markers,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: true,
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentAddress,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Drag the marker to adjust the exact location',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, _currentAddress);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Confirm Location',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}