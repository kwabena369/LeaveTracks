import 'dart:convert';
// where is the hope going to come from
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
// hope you are fine 
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
// ghost are real 
  @override
  _CameraScreenState createState() => _CameraScreenState();
}
//hope there are 
class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  Future<void> _takePictureAndUpload() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      print(base64Image);
      await _uploadImage(base64Image);
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _uploadImage(String base64Image) async {
    const url = 'https://leave-tracks-backend.vercel.app/UploadImage';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {'image': base64Image},
      );
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Screen')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePictureAndUpload,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
