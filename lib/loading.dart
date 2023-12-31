import 'package:flutter/material.dart';

Widget buildWidget(bool saving) {
  return Container(
    padding: const EdgeInsets.all(0.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (saving)
          Expanded(
            child: Container(
              color: Colors.green.withOpacity(0.25),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(), // 加入轉圈圈
                    SizedBox(height: 10.0), // 可以添加一些垂直間距
                    Text(
                      '辨識人類身分中...',
                      style: TextStyle(
                        color: Color.fromARGB(255, 178, 31, 21),
                        fontWeight: FontWeight.bold,
                        fontSize: 30.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
      ],
    ),
  );
}
