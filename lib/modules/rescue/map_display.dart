import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapDisplay extends StatefulWidget {
  final String placeName;
  final LatLng? initialPosition;
  
  const MapDisplay({
    Key? key,
    required this.placeName,
    this.initialPosition,
  }) : super(key: key);

  @override
  State<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay> {
  GoogleMapController? _mapController;
  LatLng? _placeLocation;
  bool _isLoading = true;
  String _errorMessage = '';
  Set<Marker> _markers = {};
  LatLng? _currentMarkerPosition;

  @override
  void initState() {
    super.initState();
    if (widget.initialPosition != null) {
      // If initial position is provided, use it directly
      setState(() {
        _placeLocation = widget.initialPosition;
        _currentMarkerPosition = widget.initialPosition;
        _isLoading = false;
        _updateMarker();
      });
      
      if (kDebugMode) {
        print('Using provided position: Lat: ${widget.initialPosition!.latitude.toStringAsFixed(6)}, Lng: ${widget.initialPosition!.longitude.toStringAsFixed(6)}');
      }
    } else {
      // Otherwise, geocode the place name
      _getPlaceCoordinates();
    }
  }

  Future<void> _getPlaceCoordinates() async {
    try {
      const String apiKey = "AIzaSyCh3SMUeApNyadOdzCMTLv2SwmCYm3vmqw";
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
          _isLoading = false;
          _updateMarker();
        });
        
        // Print initial coordinates to terminal
        if (kDebugMode) {
          print('Initial marker position: Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}');
        }
        
        // Move camera to the location
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

  void _updateMarker() {
    if (_currentMarkerPosition != null) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('selected_place'),
            position: _currentMarkerPosition!,
            infoWindow: InfoWindow(
              title: widget.placeName,
              snippet: 'Drag to adjust position',
            ),
            draggable: true,
            onDragStart: (LatLng position) {
              if (kDebugMode) {
                print('Started dragging marker');
              }
            },
            onDragEnd: (LatLng newPosition) {
              setState(() {
                _currentMarkerPosition = newPosition;
              });
              
              // Print new coordinates to terminal
              if (kDebugMode) {
                print('New marker position: Lat: ${newPosition.latitude.toStringAsFixed(6)}, Lng: ${newPosition.longitude.toStringAsFixed(6)}');
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
        title: Text(
          widget.placeName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          widget.placeName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (_currentMarkerPosition != null)
                                          Text(
                                            'Lat: ${_currentMarkerPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentMarkerPosition!.longitude.toStringAsFixed(6)}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
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
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  if (_currentMarkerPosition != null) {
                                    if (kDebugMode) {
                                      print('Confirmed location: Lat: ${_currentMarkerPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentMarkerPosition!.longitude.toStringAsFixed(6)}');
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Location confirmed: Lat: ${_currentMarkerPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentMarkerPosition!.longitude.toStringAsFixed(6)}'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Confirm Location'),
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