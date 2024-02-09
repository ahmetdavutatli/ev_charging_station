import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ev_charging_station/models/station_model.dart';

class StationService {
  final CollectionReference stationsCollection =
  FirebaseFirestore.instance.collection('stations');

  // Fetch all stations from Firestore
  Future<List<Station>> getStations() async {
    try {
      QuerySnapshot querySnapshot = await stationsCollection.get();
      return querySnapshot.docs
          .map((doc) => Station.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting stations: $e');
      return [];
    }
  }
}