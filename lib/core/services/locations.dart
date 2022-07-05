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
    print('_permissionGranted00');
    print(_permissionGranted);
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future getLocation() async {
    LocationData locationData;
    bool _bgModeEnabled = await location.isBackgroundModeEnabled();
    Map dataLocation = {};
    try {
      locationData = await location.getLocation();
      dataLocation['latitude'] = locationData.latitude;
      dataLocation['longitude'] = locationData.longitude;
      return dataLocation;
    } catch (e) {
      dataLocation['latitude'] = 0.0;
      dataLocation['longitude'] = 0.0;
      return dataLocation;
    }
  }
}
