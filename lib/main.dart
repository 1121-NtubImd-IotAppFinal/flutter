import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:iotappfinal_flutter/backend.dart';
import 'dart:async';
import 'package:iotappfinal_flutter/loading.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:intl/intl.dart';
import 'mqtt.dart';
import 'package:flutter_tts/flutter_tts.dart';

late List<CameraDescription> _cameras;
late MqttServerClient client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const CameraApp());
  client = await createMqttClient('flutter');
  await Future.delayed(const Duration(milliseconds: 2000), () async {
    subscribeToTopic(client, 'flutter/sign');
  });
  
}



class CameraApp extends StatefulWidget {
  
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}
class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  late Timer faceRecognitionTimer;
  FlutterTts flutterTts = FlutterTts();
  String titleTime = '';
  String titleStatus = '待機中...';
  Color titleColor = Colors.orange;
  bool _saving = false;


@override
void initState() {
  super.initState();
  updateTime();
  flutterTts.setLanguage("zh-CN");
  flutterTts.setPitch(1.0);
  flutterTts.setSpeechRate(0.5);
  controller = CameraController(_cameras[1], ResolutionPreset.max);
  controller.initialize().then((_) {
    controller.startImageStream((CameraImage availableImage) => processCameraImage(availableImage));
  }).catchError((Object e) {
    print("Camera initialization error: $e");
  });
  faceRecognitionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    listenToMqttMessages();
    updateTime();
    sendMessage(client, 'flutter/state','');
  });
  setState(() {});
}


Future<void> listenToMqttMessages() async {
  client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
    final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
    final String cardId = MqttPublishPayload.bytesToStringAsString(message.payload.message);
    setState(() { 
      _saving = true;           
      titleStatus = '正在處理中，請稍後...';
      titleColor = Colors.blue;
    });
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      XFile imageFile = await _getCameraImage();
      String req = await sendImageFileToApi(imageFile, cardId);
      String tmpText = '人臉辨識失敗，請重新操作';
      String topic = 'sign/fail';
      Color tmpColor = Colors.red;
      if(req != 'error'){
        List<String> data = req.split(',');
        topic = 'sign/success';
        if(data[1] == 'in'){
          flutterTts.speak("${data[3]} 簽到成功");
          tmpText = "${data[3]}(學號:${data[2]}) 簽到成功 !";
          tmpColor = Colors.green;
        }else {
          flutterTts.speak("${data[3]} 簽退成功");
          tmpText = "${data[3]}(學號:${data[2]}) 簽退成功 !";
          tmpColor = Colors.yellow;
        }
      }else {
        flutterTts.speak(tmpText);
      }
      setState(() {
        _saving = false;
        titleStatus = tmpText;
        titleColor = tmpColor;
      });
      sendMessage(client, topic,'');
    });
    await Future.delayed(const Duration(milliseconds: 5000), () async {
      setState(() {
        titleStatus = '待機中...';
        titleColor = Colors.orange;
      });
      sendMessage(client, 'oled/signShow','');
    });
    
  });
}

Future<XFile> _getCameraImage() async {
  try {
      XFile imageFile = await controller.takePicture();
      return imageFile;
  } catch (e) {
      print('Error getting camera image: $e');
      throw e;
  }
}
  
void processCameraImage(CameraImage image) async {
  setState(() {});
}


void updateTime() {
    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    setState(() {
      titleTime = "現在時間：$formattedTime";
    });
  }

@override
void dispose() {
  controller.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          CameraPreview(controller),
          ModalProgressHUD(inAsyncCall: false, child: buildWidget(_saving)),
          Positioned(
            top: 1,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              color: Colors.black.withOpacity(0.7), // 背景黑色，透明度為0.7
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titleTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  titleStatus,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 25.0,
                  ),
                ),
              ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
