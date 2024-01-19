import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/pages/visitor/visitor_traked_location_paint.dart';

final _paintType = StateProvider((ref) => PaintType.point);

class STrackedLocation extends ConsumerWidget {
  final List beaconInfos;
  const STrackedLocation({required this.beaconInfos});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQuery.of(context);
    final canvasWidth = mq.size.width - 70;
    final paintType = ref.watch(_paintType);

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Switch(
              value: paintType == PaintType.line,
              onChanged: (val) {
                if(paintType == PaintType.line){
                  ref.read(_paintType.notifier).update((state) => PaintType.point);
                  return;
                }
                ref.read(_paintType.notifier).update((state) => PaintType.line);
              },
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 50),
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.white,
              child: Center(
                child: Container(
                  width: canvasWidth,
                  height: canvasWidth * 0.75,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 3, color: Colors.black87),
                  ),
                  child: CustomPaint(
                    painter: FootprintsPainter(beaconInfos: beaconInfos, paintType: paintType),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
