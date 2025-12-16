import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'add_activity_screen.dart'; // We will create this next

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError("Kamera bulunamadı.");
        return;
      }

      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.low, 
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } on CameraException catch (e) {
      String errorText = "Kamera hatası: ${e.description}";
      if (e.code == 'CameraAccessDenied') {
        errorText = "Kamera erişim izni reddedildi. Lütfen tarayıcı/cihaz ayarlarından izin verin.";
      }
      _showError(errorText);
    } catch (e) {
      _showError("Bilinmeyen bir hata oluştu: $e");
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      
      if (!mounted) return;

      // Navigate to Add Activity Screen with the image path
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddActivityScreen(imagePath: image.path),
        ),
      );

    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: FloatingActionButton(
                onPressed: _takePicture,
                backgroundColor: Colors.white,
                child: const Icon(Icons.camera_alt, color: Colors.black, size: 32),
              ),
            ),
          )
        ],
      ),
    );
  }
}
