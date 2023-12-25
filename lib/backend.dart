import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> sendImageFileToApi(File imageFile) async {
  try {
    Uri apiUrl = Uri.parse('http://140.131.115.161:8000/sign'); // 添加协议 http
    var request = http.MultipartRequest('POST', apiUrl);

    // 添加文件
    var file = await http.MultipartFile.fromPath('file', imageFile.path);
    request.files.add(file);

    // 添加其他字段
    request.fields['card_id'] = '0x25e7b749';
    request.fields['token'] = 'p+8bwe~s_74;`?%nq}#?t7~p7_rr6qe_&###@*ky//}f^!_b=&00852!sr:sz!a';

    var response = await request.send();
    if (response.statusCode == 200) {
      print('API Response: ${await http.Response.fromStream(response).toString()}');
    } else {
      print('API Request Failed: ${response.statusCode}');
    }
  } catch (error) {
    print('Error sending image to API: $error');
  }
}
