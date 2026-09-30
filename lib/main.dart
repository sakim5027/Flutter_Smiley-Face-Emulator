// In-Class Activity 06 — Drawing with Flutter
// Student: Seul An Kim
// Date: September 26, 2026

import 'package:flutter/material.dart';

import 'dart:math' show pi;

void main() => runApp(const SmileyApp());

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Drawing "state" — changing these + setState() triggers shouldRepaint
  double mood = 0.8; // 0.0 sad → 1.0 happy
  double eyeRadius = 15;
  double eyeGap = 0.35;
  bool showBlush = true;
  Color faceColor = Colors.amber;
  String selectedFace = 'happy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: SmileyPainter(
                  mood: mood,
                  eyeRadius: eyeRadius,
                  eyeGap: eyeGap,
                  showBlush: showBlush,
                  faceColor: faceColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Mood: ${mood.toStringAsFixed(2)}'),
                  Slider(
                    value: mood,
                    onChanged: (double v) => setState(() => mood = v),
                  ),
                  Text('Eye radius: ${eyeRadius.toStringAsFixed(0)}'),
                  Slider(
                    min: 8,
                    max: 24,
                    value: eyeRadius,
                    onChanged: (double v) => setState(() => eyeRadius = v),
                  ),
                  Text('Eye gap: ${eyeGap.toStringAsFixed(2)}'),
                  Slider(
                    min: 0.2,
                    max: 0.6,
                    value: eyeGap,
                    onChanged: (double v) => setState(() => eyeGap = v),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Blush'),
                    value: showBlush,
                    onChanged: (bool? value) =>
                        setState(() => showBlush = value ?? false),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedFace,
                    decoration: const InputDecoration(labelText: 'Expression'),
                    items: const [
                      DropdownMenuItem(value: 'happy', child: Text('Happy')),
                      DropdownMenuItem(value: 'sad', child: Text('Sad')),
                      DropdownMenuItem(value: 'robot', child: Text('Robot')),
                    ],
                    onChanged: (String? value) {
                      if (value == null) return;

                      setState(() {
                        selectedFace = value;

                        if (value == 'happy') {
                          mood = 0.9;
                          showBlush = true;
                          faceColor = Colors.amber;
                          eyeRadius = 15;
                          eyeGap = 0.35;
                        } else if (value == 'sad') {
                          mood = 0.2;
                          showBlush = false;
                          faceColor = Colors.lightBlue;
                          eyeRadius = 15;
                          eyeGap = 0.35;
                        } else if (value == 'robot') {
                          mood = 0.5;
                          showBlush = false;
                          faceColor = Colors.lightGreen;
                          eyeRadius = 12;
                          eyeGap = 0.45;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.eyeRadius,
    required this.eyeGap,
    required this.showBlush,
    required this.faceColor,
  });

  final double mood;
  final double eyeRadius;
  final double eyeGap;
  final bool showBlush;
  final Color faceColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Modules 2–3: add eyes and mouth here. Base every position on size, center, or radius.
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.40;

    // 1) Face
    canvas.drawCircle(c, r, Paint()..color = faceColor);

    // 2) Face border
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // 3) Eyes
    final eyePaint = Paint()..color = Colors.black87;
    final eyeY = c.dy - r * 0.18;
    final eyeDx = r * eyeGap;
    canvas.drawCircle(Offset(c.dx - eyeDx, eyeY), eyeRadius, eyePaint);
    canvas.drawCircle(Offset(c.dx + eyeDx, eyeY), eyeRadius, eyePaint);

    if (showBlush) {
      final blushPaint = Paint()..color = const Color(0x73E91E63);
      final blushY = c.dy + r * 0.12;
      final blushWidth = r * 0.32;
      final blushHeight = r * 0.16;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx - r * 0.58, blushY),
          width: blushWidth,
          height: blushHeight,
        ),
        blushPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(c.dx + r * 0.58, blushY),
          width: blushWidth,
          height: blushHeight,
        ),
        blushPaint,
      );
    }

    // 4) Mouth — map mood (0..1) to arc geometry
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final mouthRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy + r * 0.15),
      width: r * 1.0,
      height: r * (0.4 + mood * 0.5),
    );

    // Happy: arc along bottom; Sad: flip with negative sweep / different start
    if (mood >= 0.5) {
      canvas.drawArc(mouthRect, 0.15 * pi, 0.70 * pi, false, mouthPaint);
    } else {
      final frownRect = mouthRect.translate(0, r * 0.25);
      canvas.drawArc(frownRect, 1.15 * pi, 0.70 * pi, false, mouthPaint);
    }

    // Import pi for arc angle math. Put this at the top of lib/main.dart.
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.eyeRadius != eyeRadius ||
        oldDelegate.eyeGap != eyeGap ||
        oldDelegate.showBlush != showBlush ||
        oldDelegate.faceColor != faceColor;
  }
}
