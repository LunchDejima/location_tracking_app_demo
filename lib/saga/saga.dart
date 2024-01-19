import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/saga/saga_initialize.dart';

final initSaga = Provider((ref) {
  final stream = ref.read(streamProvider);

  SagaInitialize(stream);
});