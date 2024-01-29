import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'package:location_tracking_app_demo/router/router_define.dart';
import 'package:location_tracking_app_demo/state/state_visitor.dart';

final _lightMode = StateProvider((ref) => false);
final _paintType = StateProvider((ref) => PaintType.point);

class STrackedLocation extends ConsumerWidget {
  const STrackedLocation() : super(key: const Key('s_tracked_location'));
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segment = ModalRoute.of(context)!.settings.arguments as RouteSegment;
    final id = segment.params!['id'];
    final mq = MediaQuery.of(context);
    final canvasWidth = mq.size.width * 0.65;
    final canvasHeight = canvasWidth * 0.8;
    final paintType = ref.watch(_paintType);
    final visitor = ref.watch(visitorProvider(id));
    final beaconInfos = visitor.beaconInfos;
    final lightMode = ref.watch(_lightMode);
    final style = TextStyle(color: lightMode ? const Color(0xFF0F0F0F) : const Color(0xFFFFFFFF));
    final footPrints = generateFootprints(
        paintType: paintType, beaconInfos: beaconInfos, size: Size(canvasWidth, canvasHeight), lightMode: lightMode);
    // ref.watch(_getData(id));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 50),
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: lightMode ? Colors.white : Colors.grey[600],
              child: Column(
                children: [
                  SizedBox(
                    width: canvasWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '表示モード',
                          style: style,
                        ),
                        const SizedBox(width: 20),
                        DropdownButton(
                          value: paintType,
                          style: style,
                          items: PaintType.values.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            ref.read(_paintType.notifier).update((state) => val ?? state);
                          },
                        ),
                        const SizedBox(width: 20),
                        Text('ライトモード', style: style),
                        Switch(
                          value: lightMode,
                          onChanged: (val) {
                            ref.read(_lightMode.notifier).update((state) => !state);
                          },
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: canvasWidth,
                      height: canvasHeight,
                      child: Stack(
                        children: footPrints,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PaintType { point, line, area }

List<Widget> generateFootprints(
    {required PaintType paintType, required List<String> beaconInfos, required Size size, required bool lightMode}) {
  final rowNum = beaconInfos.length ~/ 9;
  const maxX = 2000;
  const maxPixelX = 1160;
  const reductionRate = maxPixelX / maxX;
  final canvasWidth = size.width;
  final cancasHeight = size.height;
  final magnification = canvasWidth / maxPixelX;

  final List<_Point> points = [];

  for (var i = 0; i < rowNum; i++) {
    final index = i * 9;
    final x = beaconInfos[index + 3];
    final y = beaconInfos[index + 4];
    points.add(_Point(x: int.parse(x), y: int.parse(y)));
  }

  const areaNumX = 10;
  const areaNumY = 8;
  const initalBoundary = maxX / areaNumX;
  final boundarysX = [];
  final boundarysY = [];
  final List<_Area> areas = [];
  int maxAreaCount = 0;
  for (var boundary = initalBoundary; boundary <= initalBoundary * areaNumX; boundary += 200) {
    boundarysX.add(boundary);
  }
  for (var boudary = initalBoundary; boudary <= initalBoundary * areaNumY; boudary += 200) {
    boundarysY.add(boudary);
  }

  for (var boundaryX in boundarysX) {
    for (var boundaryY in boundarysY) {
      //

      //
      _Area area = _Area(
        x: (boundaryX - 100),
        y: (boundaryY - 100),
      );
      for (var point in points) {
        final x = point.x;
        final y = point.y;
        final boundaryFirstX = boundaryX - 200;
        final boundaryFirstY = boundaryY - 200;

        if (x >= boundaryFirstX && x <= boundaryX && y >= boundaryFirstY && y <= boundaryY) {
          area.addCount();
        }
      }
      areas.add(area);
      if (area.count > maxAreaCount) maxAreaCount = area.count;
    }
  }

  final pointsOffset = points.map((point) {
    // cm -> px  * magnification
    final x = point.x * reductionRate * magnification;
    final y = point.y * reductionRate * magnification;

    return Offset(x, y);
  }).toList();

  return [
    Positioned(
      top: 0,
      left: 0,
      child: SizedBox(
        width: canvasWidth,
        height: cancasHeight,
        child: lightMode ? Image.asset('assets/room_map.png') : Image.asset('assets/room_map_dark.png'),
      ),
    ),
    Positioned(
      top: 0,
      left: 0,
      child: Container(
        width: canvasWidth,
        height: cancasHeight,
        decoration: BoxDecoration(
          // color: Colors.white,
          border: Border.all(width: 3, color: Colors.black87),
        ),
        child: CustomPaint(
          painter: paintType != PaintType.area
              ? FootprintsPainter(
                  paintType: paintType,
                  magnification: magnification,
                  pointsOffset: pointsOffset,
                  rowNum: rowNum,
                )
              : _AreaPainter(
                  areas: areas,
                  maxAreaCount: maxAreaCount,
                  paintType: paintType,
                  magnification: magnification,
                  reductionRate: reductionRate),
        ),
      ),
    ),
  ];
}

class AreaCategories {
  static const apartment = 'apartment';
  static const luxuryApartment = 'luxuryApartment';
  static const colorSelect = 'colorSelect';
  static const tileSelect = 'tileSelect';
  static const degitalTwin = 'degitalTwin';
  static const door = 'door';
  static const none = 'none';
}

class _Area {
  final int x;
  final int y;
  String areaCategory = AreaCategories.none;
  int count = 0;
  _Area({required this.x, required this.y}) {
    if (x >= 0 && x <= 700 && y >= 0 && y <= 700) areaCategory = AreaCategories.luxuryApartment;
    if (x >= 0 && x <= 300 && y >= 900 && y <= 1500) areaCategory = AreaCategories.apartment;
    if (x >= 700 && x <= 1100 && y >= 300 && y <= 500) areaCategory = AreaCategories.colorSelect;
    if (x >= 700 && x <= 1300 && y == 700) areaCategory = AreaCategories.tileSelect;
    if (x >= 900 && x <= 1300 && y >= 900 && y <= 1500) areaCategory = AreaCategories.degitalTwin;
    if (x >= 500 && x <= 900 && y >= 1100 && y <= 1300) areaCategory = AreaCategories.door;
  }

  void addCount() {
    count++;
  }
}

class _Point {
  final int x;
  final int y;
  _Point({required this.x, required this.y});
}

class _AreaPainter extends CustomPainter {
  final List<_Area> areas;
  final int maxAreaCount;
  final PaintType paintType;
  final double magnification;
  final double reductionRate;

  _AreaPainter(
      {required this.areas,
      required this.paintType,
      required this.maxAreaCount,
      required this.magnification,
      required this.reductionRate});

  @override
  void paint(Canvas canvas, Size size) async {
    for (var area in areas) {
      final areaOffset = [Offset(area.x * reductionRate * magnification, area.y * reductionRate * magnification)];
      final count = area.count;
      final areaCountQuarter = (maxAreaCount / 4).floor();
      const pointWidth = 30;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.blue.withOpacity(0.4)
        ..strokeWidth = pointWidth * magnification
        ..strokeCap = StrokeCap.round;

      if (count >= 1 && count < areaCountQuarter) {
        canvas.drawPoints(ui.PointMode.points, areaOffset, paint);
      } else if (count >= areaCountQuarter && count < areaCountQuarter * 2) {
        paint.color = Colors.green.withOpacity(0.4);

        for (var i = 1; i <= 2; i++) {
          paint.strokeWidth = pointWidth * i * magnification;
          canvas.drawPoints(ui.PointMode.points, areaOffset, paint);
        }
      } else if (count >= areaCountQuarter * 2 && count < areaCountQuarter * 3) {
        paint.color = Colors.orange.withOpacity(0.4);
        for (var i = 1; i <= 3; i++) {
          paint.strokeWidth = pointWidth * i * magnification;
          canvas.drawPoints(ui.PointMode.points, areaOffset, paint);
        }
      } else if (count >= areaCountQuarter * 3) {
        paint.color = Colors.red.withOpacity(0.4);
        for (var i = 1; i <= 4; i++) {
          paint.strokeWidth = (pointWidth + 5) * i * magnification;
          canvas.drawPoints(ui.PointMode.points, areaOffset, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class FootprintsPainter extends CustomPainter {
  final PaintType paintType;
  final double magnification;
  final int rowNum;
  final List<Offset> pointsOffset;

  FootprintsPainter({
    required this.paintType,
    required this.magnification,
    required this.rowNum,
    required this.pointsOffset,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20 * magnification
      ..strokeCap = StrokeCap.round;

    if (rowNum == 1) {
      final color = const Color(0xFF5CB3FB).withOpacity(0.4);
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
    return false;
  }
}
