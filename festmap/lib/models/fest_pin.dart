import 'package:cloud_firestore/cloud_firestore.dart';

class FestPin {
  const FestPin({
    required this.id,
    required this.lat,
    required this.lng,
    required this.location,
    required this.activity,
    required this.size,
    required this.direction,
    required this.attire,
    required this.observedAt,
    required this.createdAt,
  });

  final String id;
  final double lat;
  final double lng;
  final String location;
  final String activity;
  final String size;
  final String direction;
  final String attire;
  final DateTime observedAt;
  final DateTime createdAt;

  factory FestPin.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FestPin(
      id: doc.id,
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      location: data['location'] as String,
      activity: data['activity'] as String,
      size: data['size'] as String,
      direction: data['direction'] as String,
      attire: data['attire'] as String,
      observedAt: DateTime.parse(data['observedAt'] as String),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

}

class PinDraft {
  const PinDraft({
    required this.lat,
    required this.lng,
    required this.location,
    required this.activity,
    required this.size,
    required this.direction,
    required this.attire,
    required this.observedAt,
  });

  final double lat;
  final double lng;
  final String location;
  final String activity;
  final String size;
  final String direction;
  final String attire;
  final DateTime observedAt;

  Map<String, dynamic> toFirestore() {
    return {
      'lat': lat,
      'lng': lng,
      'location': location,
      'activity': activity,
      'size': size,
      'direction': direction,
      'attire': attire,
      'observedAt': observedAt.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  FestPin toFestPin(String id, DateTime createdAt) {
    return FestPin(
      id: id,
      lat: lat,
      lng: lng,
      location: location,
      activity: activity,
      size: size,
      direction: direction,
      attire: attire,
      observedAt: observedAt,
      createdAt: createdAt,
    );
  }
}
