import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';

class CarService {
  final CollectionReference _carsCollection = FirebaseFirestore.instance.collection('cars');

  Future<List<Car>> getCars() async {
    try {
      QuerySnapshot querySnapshot = await _carsCollection.get();
      return querySnapshot.docs.map((doc) => Car(
        id: doc.id,
        carName: doc['carName'],
        manufacturer: doc['manufacturer'],
        initialCharge: doc['initialCharge']?.toDouble() ?? 0.0,
      )).toList();
    } catch (e) {
      print('Error fetching cars: $e');
      return [];
    }
  }
}