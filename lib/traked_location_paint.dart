import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class FootprintsPainter extends CustomPainter {
  final List beaconInfos;
  FootprintsPainter({required this.beaconInfos});
  @override
  void paint(Canvas canvas, Size size) async {

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.4)
      // ..shader = LinearGradient(colors: colors)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final infos = beaconInfos;
    final rowNum = infos.length ~/ 9;
    List<Map<String, String>> points = [];
    for (var i = 0; i < rowNum; i++) {
      final index = i * 9;
      final x = infos[index + 3];
      final y = infos[index + 4];
      points.add({'x': x, 'y': y});
    }

    final pointsOffset = points.map((info) {
      final x = int.parse(info['x']!) * 0.6 / 2;
      final y = int.parse(info['y']!) * 0.6 / 2;

      return Offset(x, y);
    }).toList();
    canvas.drawPoints(ui.PointMode.polygon, pointsOffset, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
