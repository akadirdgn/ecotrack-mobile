import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/activity_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart'; // Added
import 'package:provider/provider.dart';

import 'package:geolocator/geolocator.dart'; // Added

class AddActivityScreen extends StatefulWidget {
  final String imagePath;

  const AddActivityScreen({super.key, required this.imagePath});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _descriptionController = TextEditingController();
  bool _isUploading = false;
  String? _selectedType = 'plastic'; // Default
  String _amountString = ""; // Default empty to force input
  Position? _currentPosition;

  // Mock Activity Types
  final List<Map<String, String>> _types = [
    {'id': 'plastic', 'name': 'Plastik Toplama'},
    {'id': 'tree', 'name': 'Ağaç Dikimi'},
    {'id': 'glass', 'name': 'Cam Geri Dönüşüm'},
  ];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen konum servisini açınız.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni reddedildi. Aktivite eklenemez.')));
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni kalıcı olarak reddedildi. Ayarlardan açınız.')));
      return;
    }

    // Get position
    _currentPosition = await Geolocator.getCurrentPosition();
  }


  Future<void> _submitActivity() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kullanıcı oturumu bulunamadı.")));
      return;
    }

    // STRICT LOCATION CHECK
    if (_currentPosition == null) {
       await _checkLocationPermission(); // Try again
       if (_currentPosition == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
           content: Text("Konum bilgisi alınamadı! Konum izni zorunludur."),
           backgroundColor: Colors.red,
         ));
         return;
       }
    }

    if (!mounted) return;
    setState(() => _isUploading = true);
    
    try {
      final activityService = ActivityService();
      
      // Calculate mock points and amount
      // Calculate mock points and amount
      double amount = double.tryParse(_amountString.replaceAll(',', '.')) ?? 0;
      
      if (amount <= 0) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
             content: Text("Lütfen geçerli bir miktar giriniz (0'dan büyük olmalı)."),
             backgroundColor: Colors.redAccent,
           ));
           setState(() => _isUploading = false);
        }
        return;
      }

      int points = (10 * amount).toInt();
      if (_selectedType == 'tree') points = (50 * amount).toInt();
      if (_selectedType == 'glass') points = (20 * amount).toInt();



      // 1. Image Strategy: Disabled (User Request)
      // User wanted to disable image adding due to network errors.
      // We still keep the camera flow but don't save the image URL for now.
      String photoData = ""; 


      await activityService.addActivity(
        userId: user.uid,
        typeId: _selectedType!,
        description: _descriptionController.text,
        photoUrl: photoData, 
        pointsEarned: points,
        amount: amount,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Aktivite kaydedildi! +$points Puan")));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aktivite Ekle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview
            // Image Preview (Removed as per request to simplify)
            // Container(
            //   height: 250,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(12),
            //     image: DecorationImage(
            //       image: FileImage(File(widget.imagePath)),
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            const Center(child: Icon(Icons.check_circle, size: 64, color: Colors.green)),
            const Center(child: Text("Fotoğraf Alındı", style: TextStyle(color: Colors.green))),
            const SizedBox(height: 16),
            
            // Type Selector
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _types.map((t) {
                return DropdownMenuItem(
                  value: t['id'], 
                  child: Text(t['name']!),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedType = v),
              decoration: const InputDecoration(labelText: "Aktivite Tipi"),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Açıklama",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Amount Input
            TextFormField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _selectedType == 'plastic' ? "Miktar (kg)" : (_selectedType == 'tree' ? "Adet" : "Miktar"),
                border: const OutlineInputBorder(),
                hintText: "Orn: 1.5",
              ),
              onChanged: (val) {
                // We'll parse this on submit
                _amountString = val;
              },
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _submitActivity,
              icon: _isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.check),
              label: Text(_isUploading ? "Kaydediliyor..." : "Paylaş ve Puan Kazan"),
            )
          ],
        ),
      ),
    );
  }
}
