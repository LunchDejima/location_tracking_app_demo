import 'package:flutter/material.dart';
import 'dart:ui' as ui;

enum PaintType {
  point,
  line,
}

class FootprintsPainter extends CustomPainter {
  final List<String> beaconInfos;
  final PaintType paintType;

  FootprintsPainter({required this.beaconInfos, required this.paintType});
  @override
  void paint(Canvas canvas, Size size) async {
    if(beaconInfos.isEmpty) return;

    final infos = beaconInfos;
    final rowNum = infos.length ~/ 9;
    final magnification = size.width / 1160;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20 * magnification
      ..strokeCap = StrokeCap.round;

    List<Map<String, String>> points = [];

    for (var i = 0; i < rowNum; i++) {
      final index = i * 9;
      final x = infos[index + 3];
      final y = infos[index + 4];
      points.add({'x': x, 'y': y});
    }

    final pointsOffset = points.map((info) {
      // cm -> px  * magnification
      final x = int.parse(info['x']!) * 0.6 * magnification;
      final y = int.parse(info['y']!) * 0.6 * magnification;

      return Offset(x, y);
    }).toList();

    if (rowNum == 1) {
      final color = const Color(0xFFF6493D).withOpacity(0.4);
      paint.color = color;
      canvas.drawPoints(
        ui.PointMode.points,
        [pointsOffset[0]],
        paint,
      );
      return;
    }
    if (paintType == PaintType.point) {
      pointsOffset.asMap().forEach((i, value) {
        final color = ColorTween(
          begin: const Color(0xFF5CB3FB).withOpacity(0.4),
          end: const Color(0xFFF6493D).withOpacity(0.4), // Change the end color as needed
        ).lerp(i / (pointsOffset.length - 1));

        paint.color = color!;
        canvas.drawPoints(
          ui.PointMode.points,
          [pointsOffset[i]],
          paint,
        );
      });
      return;
    }

    for (int i = 0; i < pointsOffset.length; i++) {
      final color = ColorTween(
        begin: Colors.blue.withOpacity(0.4),
        end: Colors.red.withOpacity(0.4), // Change the end color as needed
      ).lerp(i / (pointsOffset.length - 1));

      paint.color = color!;

      if (i == pointsOffset.length - 1) {
        canvas.drawLine(
          pointsOffset[i],
          pointsOffset[i],
          paint,
        );
        continue;
      }
      canvas.drawLine(
        pointsOffset[i],
        pointsOffset[i + 1],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
