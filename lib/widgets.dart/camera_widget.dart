import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../main.dart';

class CameraWidget extends StatefulWidget {
  final Function(String) onImageCaptured;

  CameraWidget({required this.onImageCaptured});

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) return;

    // Use front camera for face capture
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final directory = await getTemporaryDirectory();
      final imagePath = path.join(
        directory.path,
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final image = await _controller!.takePicture();
      await image.saveTo(imagePath);

      widget.onImageCaptured(imagePath);
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Initializing camera...'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CameraPreview(_controller!),
            ),
          ),
        ),
        SizedBox(height: 20),
        FloatingActionButton(
          onPressed: _captureImage,
          backgroundColor: Colors.blue[600],
          child: Icon(Icons.camera_alt, color: Colors.white),
        ),
      ],
    );
  }
}
