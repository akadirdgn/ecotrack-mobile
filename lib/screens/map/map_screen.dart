import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../services/map_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import '../../models/activity_model.dart'; // For filters or display
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(38.3552, 38.3095); // Default: Malatya (Hürriyet Parkı)
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition().catchError((error) {
        print("Uncaught error in _determinePosition: $error");
      });
    });
  }

  Future<void> _determinePosition() async {
    try {
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
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Konum izni reddedildi. Harita varsayılan konumu gösteriyor.')),
             );
           }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
         setState(() => _isLoading = false);
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Konum izni kalıcı olarak reddedildi. Ayarlardan izin verebilirsiniz.')),
           );
         }
        return;
      }

      // 3. Get Position
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _mapController.move(_currentPosition, 15);
    } catch (e) {
      print("Error getting location: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum alınamadı. Varsayılan konum kullanılıyor.')),
        );
      }
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
                tileProvider: CancellableNetworkTileProvider(),
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
                  // 2. Build markers and return with FutureBuilder for eco spots
                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('eco_spots').get(),
                    builder: (context, ecoSnapshot) {
                      // Add eco spots to markers if available
                      if (ecoSnapshot.hasData) {
                        for (var doc in ecoSnapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                    final lat = (data['latitude'] as num).toDouble();
                    final lng = (data['longitude'] as num).toDouble();
                    final name = data['name'] as String;
                    final type = data['type'] as String;

                    // Icon and color based on type
                    IconData spotIcon;
                    Color spotColor;
                    switch (type) {
                      case 'water':
                        spotIcon = Icons.water_drop;
                        spotColor = Colors.blue[700]!;
                        break;
                      case 'recycle':
                        spotIcon = Icons.recycling;
                        spotColor = Colors.green[700]!;
                        break;
                      case 'tree':
                        spotIcon = Icons.park;
                        spotColor = Colors.orange[800]!;
                        break;
                      default:
                        spotIcon = Icons.location_on;
                        spotColor = Colors.grey;
                    }

                    activityMarkers.add(
                      Marker(
                        point: LatLng(lat, lng),
                        width: 80,
                        height: 80,
                        child: Column(
                          children: [
                            Icon(spotIcon, color: spotColor, size: 40),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                      }

                      // Return MarkerLayer with all markers
                      return MarkerLayer(
                        markers: [
                          // User Location (Blue)
                          Marker(
                            point: _currentPosition,
                            width: 60,
                            height: 80, // Increased height to fix overflow
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
                    }, // Close FutureBuilder builder
                  ); // Close FutureBuilder
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
        ],
      ),
    );
  }
}
