import 'package:flutter/material.dart';
import 'package:new_vigilai/pages/home_page/pages/matrix.dart';


class cloud extends StatelessWidget {
  const cloud({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8F9FF),
      body: Stack(
        children: [
          const MatrixRainEffect(), // Matrix rain background
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud, size: 80, color: Colors.black),
                const SizedBox(height: 20),
                const Text(
                  "cloud",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
