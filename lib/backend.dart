import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

Future<String> sendImageFileToApi(XFile imageFile, String card_id) async {
  try {
    Uri apiUrl = Uri.parse('http://140.131.115.152:80/sign'); // 添加协议 http
    var request = http.MultipartRequest('POST', apiUrl);
    // final tempDir = await getTemporaryDirectory();
    // final filePath = '${tempDir.path}/output_image.png';
    // final imageFile = await File(filePath).writeAsBytes(imglib.encodePng(convertYUV420ToImage(image)));

    // 添加文件
    var file = await http.MultipartFile.fromPath('file', imageFile.path);
    request.files.add(file);

    // 添加其他字段
    request.fields['card_id'] = card_id;
    request.fields['token'] = 'p+8bwe~s_74;`?%nq}#?t7~p7_rr6qe_&###@*ky//}f^!_b=&00852!sr:sz!a';

    var response = await request.send();
    String responseBody = await response.stream.bytesToString();
    return responseBody;
  } catch (error) {
    print('Error sending image to API: $error');
    return 'error'; // 或者返回一個預設值，視情況而定
  }
}
