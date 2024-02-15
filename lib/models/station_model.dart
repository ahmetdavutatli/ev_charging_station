class Station {
  final String id;
  final int? stationID;
  final String activeHours;
  final double fee;
  bool isEmpty;
  final String name;
  final double latitude;
  final double longitude;
  final String address;

  Station({
    required this.id,
    required this.stationID,
    required this.activeHours,
    required this.fee,
    required this.isEmpty,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  // Factory method to create a Station object from Firestore data
  factory Station.fromFirestore(Map<String, dynamic> data, String documentId) {
    print('Data received: $data');

    final id = documentId;
    final stationID = data['stationID'];
    final activeHours = data['activeHours'];
    final fee = data['fee'];
    final isEmpty = data['isEmpty'];
    final name = data['name'];
    final latitude = data['latitude'];
    final longitude = data['longitude'];
    final address = data['address'];

    print('ID: $id, Name: $name, Latitude: $latitude, Longitude: $longitude, Address: $address, Fee: $fee, IsEmpty: $isEmpty, Active Hours: $activeHours, Station ID: $stationID');

    return Station(
      id: id,
      stationID: stationID,
      activeHours: activeHours,
      fee: fee.toDouble(),
      isEmpty: isEmpty,
      name: name,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      address: address,
    );
  }
}