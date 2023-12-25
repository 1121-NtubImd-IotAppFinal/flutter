import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:iotappfinal_flutter/backend.dart';
import 'dart:async';
import 'package:iotappfinal_flutter/cameraToPng.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;

late List<CameraDescription> _cameras;
var isRecovered = 0;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}
class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  late Timer faceRecognitionTimer;

@override
void initState() {
  super.initState();
  controller = CameraController(_cameras[1], ResolutionPreset.max);
  controller.initialize().then((_) {
    controller.startImageStream((CameraImage availableImage) => processCameraImage(availableImage));

    
    
  }).catchError((Object e) {
    print("Camera initialization error: $e");
  });
  setState(() {});
}


void processCameraImage(CameraImage image) async {
  isRecovered = isRecovered +1;
  setState(() {});
  print("test");
  if(isRecovered % 100 == 0){
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/output_image.png';
      await File(filePath).writeAsBytes(imglib.encodePng(convertYUV420ToImage(image)));
      sendImageFileToApi(File(filePath));  
  }
}


@override
void dispose() {
  controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  if (!controller.value.isInitialized) {
    return Container();
  }
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          CameraPreview(controller),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              color: Colors.black.withOpacity(0.7), // 背景黑色，透明度為0.7
              child: const Center(
                child: Text(
                  'Your Text Here',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
