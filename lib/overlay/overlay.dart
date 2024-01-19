import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/overlay/overlay_define.dart';

final initOverlay = Provider((ref) {
  ref.read(streamProvider).listen((value) {
    //
  });
});

final showAlert = Provider((ref) {
  return ({
    required Widget Function(BuildContext context) builder,
    VoidCallback? callback,
  }) {
    ref.read(streamProvider).add(AlertOverlayShow(
          builder: builder,
          callback: callback,
        ));
  };
});
final hideAlert = Provider((ref) {
  return () {
    ref.read(streamProvider).add(AlertOverlayHide());
  };
});
