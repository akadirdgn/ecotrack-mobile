import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../services/map_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(41.0082, 28.9784); // Default: Istanbul
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check Service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled.
      setState(() => _isLoading = false);
      return;
    }

    // 2. Check Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
         setState(() => _isLoading = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
       setState(() => _isLoading = false);
      return;
    }

    // 3. Get Position
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_currentPosition, 15);
    } catch (e) {
      print("Error getting location: $e");
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    // Listen to navigation requests
    final mapState = Provider.of<MapState>(context);
    
    // If there is a target and map is ready
    if (mapState.targetLocation != null) {
      // Move map
       WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(mapState.targetLocation!, mapState.targetZoom);
          // CRITICAL: Clear the target so we don't get stuck in this tab!
          // We must do this, otherwise HomeScreen will keep pushing us back to Map tab.
          Provider.of<MapState>(context, listen: false).clearTarget();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ecotrack',
              ),
               
               // Real-time Activity stream
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('activities').snapshots(),
                builder: (context, snapshot) {
                  List<Marker> activityMarkers = [];

                  // 1. Real Data from Firestore
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final double? lat = (data['latitude'] as num?)?.toDouble();
                      final double? lng = (data['longitude'] as num?)?.toDouble();
                      final String typeId = data['typeId'] ?? 'general';
                      
                      if (lat != null && lng != null) {
                        activityMarkers.add(
                          Marker(
                            point: LatLng(lat, lng),
                            width: 60,
                            height: 60,
                            child: Column(
                              children: [
                                Icon(Icons.location_on, color: Colors.green[700], size: 40),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  color: Colors.white,
                                  child: Text(typeId == 'plastic' ? 'Plastik' : 'Etkinlik', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                )
                              ],
                            ),
                          )
                        );
                      }
                    }
                  }

                  // 2. Malatya Suggested Spots (Requested)
                  final malatyaSpots = [
                     {'lat': 38.3552, 'lng': 38.3095, 'title': 'Hürriyet Parkı'},
                     {'lat': 38.3430, 'lng': 38.3140, 'title': 'Sümer Park'},
                     {'lat': 38.3300, 'lng': 38.3500, 'title': 'Orduzu Pınarbaşı'},
                     {'lat': 38.4000, 'lng': 38.2500, 'title': 'Beydağı Ormanı'},
                  ];

                  for (var spot in malatyaSpots) {
                    activityMarkers.add(
                      Marker(
                        point: LatLng(spot['lat'] as double, spot['lng'] as double),
                        width: 80,
                        height: 80,
                        child: Column(
                          children: [
                            Icon(Icons.park, color: Colors.orange[800], size: 40),
                            Container(
                               padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                               child: Text(spot['title'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                             ),
                          ],
                        ),
                      )
                    );
                  }

                  return MarkerLayer(
                    markers: [
                      // User Location (Blue)
                      Marker(
                        point: _currentPosition,
                        width: 60,
                        height: 60,
                        child: const Column(
                          children: [
                            Icon(Icons.person_pin_circle, color: Colors.blueAccent, size: 50),
                            Text("Ben", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                      ...activityMarkers,
                    ],
                  );
                },
              )
            ],
          ),
          
          // Overlay UI
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
            
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'map_fab',
              onPressed: _determinePosition,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          
          Positioned(
            top: 50,
            left: 20,
            child: Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Aktivite Haritası", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text("Yakınındaki etkinlikleri keşfet", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
