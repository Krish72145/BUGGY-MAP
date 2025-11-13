import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveLocation({
    required String userId,
    required String label,
    required double latitude,
    required double longitude,
  }) async {
    await _db.collection('locations').add({
      'userId': userId,
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getUserLocations(String userId) {
    return _db.collection('locations').where('userId', isEqualTo: userId).get();
  }
}