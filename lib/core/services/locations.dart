import 'package:location/location.dart';
import 'package:flutter/material.dart';

class Locations {
  Locations._private();

  factory Locations() {
    return _instance;
  }

  static final Locations _instance = Locations._private();

  // static Location? location;
  Location location = new Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;

  Future<void> permissionLocation() async {
    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<LocationData> getLocation() async {
    LocationData locationData;

    locationData = await location.getLocation();
    return locationData;
  }
}
