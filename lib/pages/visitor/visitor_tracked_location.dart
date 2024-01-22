import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/etc/logger.dart';
import 'package:location_tracking_app_demo/pages/visitor/visitor_traked_location_paint.dart';
import 'package:location_tracking_app_demo/router/router_define.dart';

final _getData = Provider.family.autoDispose((ref, id) async {
  try {
    final strageRef = FirebaseStorage.instance.ref();
    final pathRef = strageRef.child('records/$id.csv');
    const oneMegabyte = 1024 * 1024;
    final data = await pathRef.getData(oneMegabyte);
    final decodedData = utf8.decode(data!);
    final re = RegExp(',|\n');
    final beaconInfos = decodedData.split(re).sublist(9);
    ref.read(_beaconInfos.notifier).update((state) => beaconInfos);
  } catch (e) {
    logger.warning(e);
  }
});

final _beaconInfos = StateProvider.autoDispose<List<String>>((ref) => []);
final _lightMode = StateProvider((ref) => true);
final _paintType = StateProvider((ref) => PaintType.point);

class STrackedLocation extends ConsumerWidget {
  const STrackedLocation() : super(key: const Key('s_tracked_location'));
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segment = ModalRoute.of(context)!.settings.arguments as RouteSegment;
    final id = segment.params!['id'];
    final mq = MediaQuery.of(context);
    final canvasWidth = mq.size.width - 350;
    final paintType = ref.watch(_paintType);
    final beaconInfos = ref.watch(_beaconInfos);
    final lightMode = ref.watch(_lightMode);
    ref.watch(_getData(id));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 50),
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    width: canvasWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Switch(
                          value: paintType == PaintType.line,
                          onChanged: (val) {
                            if (paintType == PaintType.line) {
                              ref.read(_paintType.notifier).update((state) => PaintType.point);
                              return;
                            }
                            ref.read(_paintType.notifier).update((state) => PaintType.line);
                          },
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: canvasWidth,
                      height: canvasWidth * 0.764,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 15,
                            left: 0,
                            child: SizedBox(
                              width: canvasWidth,
                              height: canvasWidth * 0.764,
                              child: lightMode
                                  ? Image.asset('assets/room_map.png')
                                  : Image.asset('assets/room_map_dark.png'),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: canvasWidth,
                              height: canvasWidth * 0.764,
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                border: Border.all(width: 3, color: Colors.black87),
                              ),
                              child: CustomPaint(
                                painter: FootprintsPainter(beaconInfos: beaconInfos, paintType: paintType),
                              ),
                            ),
                          ),
                        ],
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
