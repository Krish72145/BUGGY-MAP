import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buggy Map - NIT Trichy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BuggyMap(),
    );
  }
}

class BuggyMap extends StatefulWidget {
  const BuggyMap({super.key});

  @override
  State<BuggyMap> createState() => _BuggyMapState();
}

class _BuggyMapState extends State<BuggyMap> {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  LatLng? _currentLocation;
  LatLng? _nearestStop;

  final List<Map<String, dynamic>> buggyStops = [
    {'name': 'Lassi Shop', 'location': LatLng(10.761750, 78.814649)},
    {'name': 'Coke Station', 'location': LatLng(10.761701, 78.813969)},
    {'name': 'GJCH', 'location': LatLng(10.761515, 78.811831)},
    {'name': 'Department of Energy and Environment', 'location': LatLng(10.759784, 78.812305)},
    {'name': 'Orion Front', 'location': LatLng(10.759719, 78.811045)},
    {'name': 'Department of Chemical Engineering', 'location': LatLng(10.758623, 78.811988)},
    {'name': 'Ojas', 'location': LatLng(10.760575, 78.808483)},
    {'name': 'Department of Architecture', 'location': LatLng(10.759830, 78.809708)},
    {'name': 'Orion Back', 'location': LatLng(10.759701, 78.810454)},
    {'name': 'Third I + Twinnet', 'location': LatLng(10.761183, 78.814282)},
    {'name': 'Logos', 'location': LatLng(10.761034, 78.814223)},
    {'name': 'Classics + CEESAT Ground', 'location': LatLng(10.760368, 78.813970)},
    {'name': 'Capstone', 'location': LatLng(10.759813, 78.814115)},
    {'name': 'Barn Hall', 'location': LatLng(10.759214, 78.814188)},
    {'name': 'Admin Building', 'location': LatLng(10.758778, 78.813191)},
    {'name': 'Admin Building Gate', 'location': LatLng(10.758091, 78.813356)},
    {'name': 'EEE Department', 'location': LatLng(10.758069, 78.814663)},
    {'name': 'Mechanical + MME', 'location': LatLng(10.758133, 78.815789)},
    {'name': 'Central Workshop', 'location': LatLng(10.760230, 78.815786)},
    {'name': 'ECE Department', 'location': LatLng(10.760653, 78.816531)},
    {'name': 'Production Department', 'location': LatLng(10.760930, 78.816508)},
    {'name': 'Lyceum Building', 'location': LatLng(10.760060, 78.817655)},
    {'name': 'CSE Department', 'location': LatLng(10.759950, 78.818516)},
  ];

  LatLng? _findNearestStop(LatLng current) {
    double minDist = double.infinity;
    LatLng? nearest;
    for (var stop in buggyStops) {
      double dist = const Distance().as(
        LengthUnit.Meter,
        current,
        stop['location'],
      );
      if (dist < minDist) {
        minDist = dist;
        nearest = stop['location'];
      }
    }
    return nearest;
  }

  void _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _nearestStop = _findNearestStop(_currentLocation!);
        _mapController.move(_currentLocation!, 17.0);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = buggyStops.map((stop) {
      final isNearest = _nearestStop == stop['location'];
      return Marker(
        point: stop['location'],
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            _popupController.hideAllPopups();
            _popupController.togglePopup(
              Marker(
                point: stop['location'],
                width: 40,
                height: 40,
                child: const SizedBox(),
              ),
            );
          },
          child: Icon(
            Icons.location_on,
            color: isNearest ? Colors.green : Colors.blueAccent,
            size: isNearest ? 40 : 30,
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buggy Map - NIT Trichy'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(10.7600, 78.8135),
          initialZoom: 16.2,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.buggy_map',
          ),

          // ✅ Use PopupMarkerLayer (not deprecated)
          PopupMarkerLayer(
            options: PopupMarkerLayerOptions(
              popupController: _popupController,
              markers: markers,
              popupDisplayOptions: PopupDisplayOptions(
                builder: (context, marker) {
                  final stop = buggyStops.firstWhere(
                        (s) => s['location'] == marker.point,
                  );
                  return Card(
                    color: Colors.white,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        stop['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (_currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 80,
                  height: 80,
                  child: const Icon(
                    Icons.person_pin_circle,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),

          if (_currentLocation != null && _nearestStop != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [_currentLocation!, _nearestStop!],
                  strokeWidth: 4.0,
                  color: Colors.greenAccent,
                ),
              ],
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getCurrentLocation,
        label: const Text('Locate Me'),
        icon: const Icon(Icons.my_location),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
