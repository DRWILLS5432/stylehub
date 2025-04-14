// address_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Address {
  final String name;
  final String details;
  final double? lat;
  final double? lng;

  Address({
    required this.name,
    required this.details,
    this.lat,
    this.lng,
  });
}

class AddressProvider with ChangeNotifier {
  final List<Address> _addresses = [];
  Address? _selectedAddress;

  List<Address> get addresses => _addresses;

  // Getter for selectedAddress
  Address? get selectedAddress => _selectedAddress;

  // Setter for selectedAddress
  set selectedAddress(Address? address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<void> addAddress(Address newAddress) async {
    _addresses.add(newAddress);
    _selectedAddress = newAddress;
    notifyListeners();
    // Save to Firestore
    await _saveToFirestore(newAddress);
  }

  Future<void> fetchAddresses() async {
    // Implement Firestore fetch logic
  }

  Future<void> _saveToFirestore(Address address) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('addresses').add({
        'name': address.name,
        'details': address.details,
        'lat': address.lat,
        'lng': address.lng,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Address> getCurrentLocationAddress() async {
    try {
      // Log service status
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('Location service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      final position = await _getCurrentLocation();
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = places.first;
      return Address(
        name: 'Current Location',
        details: '${place.street}, ${place.locality}, ${place.country}',
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }
}
