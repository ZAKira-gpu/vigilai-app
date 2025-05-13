import 'dart:math';
import 'package:flutter/material.dart';

class MatrixRainEffect extends StatefulWidget {
  const MatrixRainEffect({super.key});

  @override
  _MatrixRainEffectState createState() => _MatrixRainEffectState();
}

class _MatrixRainEffectState extends State<MatrixRainEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();
  final _columns = 40;
  final _charSet = '01zakianis';
  late List<double> _drops;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150))
      ..addListener(() {
        setState(() {
          // Move drops down
          for (int i = 0; i < _drops.length; i++) {
            _drops[i] += 0.3; // Slower drop speed
            if (_drops[i] * 20 > MediaQuery
                .of(context)
                .size
                .height || _random.nextDouble() > 0.995) {
              _drops[i] = 0;
            }
          }




        });
      })
      ..repeat();

    _drops = List.generate(_columns, (index) => _random.nextDouble() * 50);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MatrixPainter(_drops, _charSet, _random),
      child: Container(), // Transparent background
    );
  }
}

class _MatrixPainter extends CustomPainter {
  final List<double> drops;
  final String charSet;
  final Random random;

  _MatrixPainter(this.drops, this.charSet, this.random);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < drops.length; i++) {
      final x = i * 20.0;
      final y = drops[i] * 20.0;

      final char = charSet[random.nextInt(charSet.length)];
      final textSpan = TextSpan(
        text: char,
        style: TextStyle(
          color: Colors.greenAccent.withOpacity(0.7),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
