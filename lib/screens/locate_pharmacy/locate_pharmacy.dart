// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class NearbyPharmaciesScreen extends StatefulWidget {
  const NearbyPharmaciesScreen({super.key});

  @override
  _NearbyPharmaciesScreenState createState() =>
      _NearbyPharmaciesScreenState();
}

class _NearbyPharmaciesScreenState extends State<NearbyPharmaciesScreen> {
  // ignore: unused_field
  late Position _currentPosition;
  bool _isLoading = true;
  List<String> _nearbyPharmacies = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _fetchNearbyPharmacies();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _fetchNearbyPharmacies() {

    setState(() {
      _nearbyPharmacies = [
        'Pharmacy 1 - Location A',
        'Pharmacy 2 - Location B',
        'Pharmacy 3 - Location C',
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Pharmacies')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _nearbyPharmacies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_nearbyPharmacies[index]),
                  subtitle: Text('Distance: 5 km'),
                );
              },
            ),
    );
  }
}
