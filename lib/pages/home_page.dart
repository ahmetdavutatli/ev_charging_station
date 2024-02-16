import 'dart:typed_data';
import 'package:ev_charging_station/services/station_services.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../models/station_model.dart';
import 'charging_page.dart';
import 'my_cars_page.dart';
import '../auth.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;
import '../navbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../selected_car.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../global_stations.dart' as global_stations;

double globalLatitude = 39.9334;  // Default initial value
double globalLongitude = 32.8597; // Default initial valuell
List<Station> stations = global_stations.stations;



class HomePage extends StatefulWidget {

  final Auth auth;

  const HomePage({Key? key, required this.auth}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  late List<Widget> _pages;



  @override
  void initState() {
    super.initState();

    // Adjusting the page list based on the items you want to keep
    _pages = [
      ChargingPage(stations: stations,),
      Consumer<SelectedCar>(
        builder: (context, selectedCar, child) {
          return HomePageContent(selectedCar: selectedCar);
        },
      ),
      MyCarsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _selectedIndex < _pages.length
          ? _pages[_selectedIndex]
          : Container(
        child: const Text('Invalid Page Selected'),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xff262930),
        color: Colors.green,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            // Adjusting the selected index
            _selectedIndex = index;
          });
        },
        items: [
          // Update the order of icons accordingly
          Icon(Icons.flash_on, size: 30),
          Icon(Icons.home, size: 30),
          Icon(Icons.directions_car_filled_sharp, size: 30),
        ],
        index: _selectedIndex,
      ),
    );
  }
}



class HomePageContent extends StatefulWidget {
  final Station? focusedStation;

  const HomePageContent({Key? key, this.focusedStation, required SelectedCar selectedCar}) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();

}



class _HomePageContentState extends State<HomePageContent> {
  GoogleMapController? _mapController;
  bool _isMapReady = false;
  Location _location = Location();
  StationService _stationService = StationService();
  BitmapDescriptor markerIconStation = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIconUser = BitmapDescriptor.defaultMarker;
  Set<Marker> _markers = <Marker>{};




  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(39.9334, 32.8597),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _loadStationMarker();
    _loadUserMarker();
  }

  Future<BitmapDescriptor> _resizeImage(Uint8List bytes, double newSize) async {
    final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
      bytes,
      targetHeight: newSize.toInt(),
    );

    final ui.FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    final ByteData? resizedByteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(resizedByteData!.buffer.asUint8List());
  }



  Future<void> _loadStationMarker() async {
    final ByteData data = await rootBundle.load('assets/station_marker.png');
    final Uint8List bytes = data.buffer.asUint8List();

    // Resize the marker icon
    double newSize = 300.0; // Adjust the size as needed
    markerIconStation = await _resizeImage(bytes, newSize);
  }

  Future<void> _loadUserMarker() async {
    final ByteData data = await rootBundle.load('assets/user_marker.png');
    final Uint8List bytes = data.buffer.asUint8List();

    // Resize the marker icon
    double newSize = 150.0; // Adjust the size as needed
    markerIconUser = await _resizeImage(bytes, newSize);
  }



  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _initializeMap() async {
    print('initializing map...');
    await _getLocation();
    if(mounted){
      setState(() {
        _isMapReady = true;
      });
    }
  }

  Future<List<Station>> fetchEVChargingStations(double latitude, double longitude) async {
    var url = Uri.parse('https://ev-charge-finder.p.rapidapi.com/search-by-coordinates-point')
        .replace(queryParameters: {
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      'limit': '11'
    });

    try {
      var response = await http.get(url, headers: {
        'X-RapidAPI-Key': '5b44f04db6msh69e2aa11abca8ddp18d7aejsn22d8c20034ff',
        'X-RapidAPI-Host': 'ev-charge-finder.p.rapidapi.com'
      });

      if (response.statusCode == 200) {
        print('Request successful.');
        var data = json.decode(response.body);
       stations = (data['data'] as List).asMap().entries.map((entry) {
          int index = entry.key + 1; // This will start the index from 1
          var station = entry.value;
          return Station(
            id: index.toString(),
            name: station['name'],
            latitude: station['latitude'],
            longitude: station['longitude'],
            address: station['formatted_address'],
          );
        }).toList();
        return stations;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return [];
      }
    } catch (error) {
      print('An error occurred: $error');
      return [];
    }
  }


  void _focusOnStation(Station station) {
    if (_mapController != null) {
      _moveToCurrentLocation(station.latitude, station.longitude);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.focusedStation != null) {
      _focusOnStation(widget.focusedStation!);
    }
  }

  Future<void> _getLocation() async {
    try {
      var location = await _location.getLocation();
      _moveToCurrentLocation(location.latitude!, location.longitude!);
      globalLatitude = location.latitude!;
      globalLongitude = location.longitude!;

    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _moveToCurrentLocation(double latitude, double longitude) {
    final _mapController = this._mapController;
    if (_mapController != null) {
      CameraPosition _currentLocation = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 15.0,
      );
      _mapController
          ?.animateCamera(CameraUpdate.newCameraPosition(_currentLocation));
    }
  }

  void _showBottomSheet({required Station station}) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.stationInfo,
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '${AppLocalizations.of(context)!.stationName} : ${station.name}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context)!.stationLocation}: ${station.address}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              Spacer(), // Push the button to the bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChargingPage(stations: stations,),
                      ),
                    );
                  },
                  icon: Icon(Icons.bolt_sharp),
                  label: Text(
                    AppLocalizations.of(context)!.reservation,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<void> _loadStations() async {
    // _mapController kontrolü
    if (_mapController == null) {
      print('Error: _mapController is null. Cannot load stations.');
      return;
    }

    // Get user's current location
    var location = await _location.getLocation();
    LatLng userLocation = LatLng(location.latitude!, location.longitude!);

    List<Marker> markers = [];

    Marker userMarker = Marker(
      markerId: MarkerId("userMarker"),
      position: userLocation,
      icon: markerIconUser,
      infoWindow: InfoWindow(
        title: "Your Location",
        snippet: "You are here",
      ),
    );
    markers.add(userMarker);

    // Marker'ları oluştur
    Future<void> _createMarkers() async {
      try {
        stations = await fetchEVChargingStations(globalLatitude, globalLongitude);

        var markers = stations.map((station) {
          return Marker(
            markerId: MarkerId(station.id),
            position: LatLng(station.latitude, station.longitude),
            icon: markerIconStation,
            onTap: () => _showBottomSheet(station: station),
          );
        }).toList();

        setState(() {
          _markers.addAll(markers);
        });
      } catch (e) {
        // Handle any errors here
        print('Error creating markers: $e');
      }
    }
    // Marker'ları oluştur
    _createMarkers();

    // Marker'ları güncelle
    setState(() {
      _markers.addAll(markers);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(auth: Auth(),),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xff262930)),
      ),
      body: _isMapReady
          ? Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _onMapCreated(controller);
              _loadStations();
            },
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            zoomControlsEnabled: false,
            compassEnabled: false,
            markers: _markers,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'zoomIn',
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.zoomIn(),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1.0,
                      height: MediaQuery.of(context).size.height * 1.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.lightGreen],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Icon(Icons.add),
                    ),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'zoomOut',
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.zoomOut(),
                      );
                    },
                    child: Icon(Icons.remove),
                    backgroundColor: Colors.green,
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'location',
                    onPressed: () {
                      _getLocation();
                    },
                    child: Icon(Icons.my_location),
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}