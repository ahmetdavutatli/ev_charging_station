import 'package:ev_charging_station/services/station_services.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../models/station_model.dart';
import 'transaction_page.dart';
import 'charging_page.dart';
import 'my_cars_page.dart';
import 'profile_page.dart';
import '../auth.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';  // Added import for Provider
import '../charge_state.dart';  // Import your ChargeState class


class HomePage extends StatefulWidget {
  final Auth auth;

  const HomePage({Key? key, required this.auth}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const TransactionPage(),
      ChargingPage(stationService: StationService()),
      MyCarsPage(),
      ProfilePage(auth: widget.auth),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff262930),
      body: _selectedIndex == 0
          ? const HomePageContent()
          : (_selectedIndex > 0 && _selectedIndex <= _pages.length)
          ? _pages[_selectedIndex - 1]
          : Container(
        child: const Text('Invalid Page Selected'),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xff262930),
        color: const Color(0xff26B6E1),
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          Icon(Icons.home, size: 30),
          Icon(Icons.access_time_filled, size: 30),
          Icon(Icons.flash_on, size: 30),
          Icon(Icons.directions_car_filled_sharp, size: 30),
          Icon(Icons.account_circle, size: 30),
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  final Station? focusedStation;

  const HomePageContent({Key? key, this.focusedStation}) : super(key: key);

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  GoogleMapController? _mapController;
  bool _isMapReady = false;
  Location _location = Location();
  StationService _stationService = StationService();
  Set<Marker> _markers = <Marker>{};

  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(39.9334, 32.8597),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }


  Future<void> _initializeMap() async {
    print('initializing map...');
    await _getLocation();
    setState(() {
      _isMapReady = true;
    });
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
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(_currentLocation));
    }
  }

  Future<void> _loadStations() async {
    try {
      if (_mapController != null) {
        // Get user's current location
        var location = await _location.getLocation();
        LatLng userLocation = LatLng(location.latitude!, location.longitude!);

        // Create a list to store markers
        List<Marker> markers = [];

        // Add user's marker
        Marker userMarker = Marker(
          markerId: MarkerId("userMarker"),
          position: userLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: "Your Location",
            snippet: "You are here",
          ),
        );
        markers.add(userMarker);

        // Load stations and add markers
        List<Station> stations = await _stationService.getStations();
        markers.addAll(stations.map((station) {
          print('Station: ${station.name}, Lat: ${station.latitude}, Lng: ${station.longitude}');
          return Marker(
            markerId: MarkerId(station.id),
            position: LatLng(station.latitude, station.longitude),
            infoWindow: InfoWindow(
              title: station.name,
              snippet: 'Tap for details',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChargingDetailsPage(station: station),
                ),
              );
            },
          );
        }));

        if (mounted) {
          setState(() {
            _markers.clear();
            _markers.addAll(markers);
          });
        }
      } else {
        print('Error: _mapController is null. Cannot load stations.');
      }
    } catch (e) {
      print('Error getting stations: $e');
    }
    print('loading stations...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anasayfa'),
        backgroundColor: const Color(0xff26B6E1),
      ),
      body: _isMapReady
          ? Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _onMapCreated(controller);
              _loadStations(); // Load stations after the map is created
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
                    child: Icon(Icons.add),
                    backgroundColor: const Color(0xff26B6E1),
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
                    backgroundColor: const Color(0xff26B6E1),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'location',
                    onPressed: () {
                      _getLocation();
                    },
                    child: Icon(Icons.my_location),
                    backgroundColor: const Color(0xff26B6E1),
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



