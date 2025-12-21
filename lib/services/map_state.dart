import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapState extends ChangeNotifier {
  LatLng? _targetLocation;
  double _targetZoom = 15.0;
  
  LatLng? get targetLocation => _targetLocation;
  double get targetZoom => _targetZoom;

  void navigateToLocation(LatLng location, {double zoom = 15.0}) {
    _targetLocation = location;
    _targetZoom = zoom;
    notifyListeners();
  }
  
  void clearTarget() {
    _targetLocation = null;
    notifyListeners();
  }
}
