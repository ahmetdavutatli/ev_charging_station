class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;

  Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  // Factory method to create a Station object from Firestore data
  factory Station.fromFirestore(Map<String, dynamic> data, String documentId) {
    print('Data received: $data');

    final id = documentId;
    final name = data['name'];
    final latitude = data['latitude'];
    final longitude = data['longitude'];
    final address = data['address'];

    print('ID: $id, Name: $name, Latitude: $latitude, Longitude: $longitude, Address: $address');

    return Station(
      id: id,
      name: name,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      address: address,
    );
  }
}