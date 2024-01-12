import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/traked_location_paint.dart';

class STrackedLocation extends ConsumerWidget{
  final List beaconInfos;
  const STrackedLocation({required this.beaconInfos});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 50),
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
              color: Colors.white,
              child: Center(
                child: Container(
                  width: 580,
                  height: 435,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 3, color: Colors.black87),
                  ),
                  child: CustomPaint(
                    size: const Size(580, 435),
                    painter: FootprintsPainter(beaconInfos: beaconInfos),
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
