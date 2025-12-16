import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/models.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  
  // Default location (e.g., Istanbul)
  final LatLng _initialPosition = const LatLng(41.0082, 28.9784);
  
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadActivityMarkers();
  }

  void _loadActivityMarkers() {
    // Mock data for visualization
    _markers.add(
      Marker(
        markerId: const MarkerId('1'),
        position: const LatLng(41.0082, 28.9784),
        infoWindow: const InfoWindow(title: 'Plastik Toplama', snippet: '50 Puan'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
     _markers.add(
      Marker(
        markerId: const MarkerId('2'),
        position: const LatLng(41.0122, 28.9764),
        infoWindow: const InfoWindow(title: 'Ağaç Dikimi', snippet: '100 Puan'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Apply dark map style if available
    // _mapController.setMapStyle(_mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Aktivite Haritası",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
