class Car {
  final String id; // Document ID in Firestore
  final String carName;
  final String manufacturer;
  final double initialCharge;

  Car({
    required this.id,
    required this.carName,
    required this.manufacturer,
    required this.initialCharge,
  });
}