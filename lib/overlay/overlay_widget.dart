import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/overlay/overlay_alert.dart';
import 'package:location_tracking_app_demo/overlay/overlay_define.dart';
import 'package:rxdart/rxdart.dart';

class _Ctrl {
  final ProviderRef ref;

  _Ctrl(this.ref) {
    Timer? timer;

    ref.read(streamProvider).whereType<OverlayEvent>().distinct().listen((value) {
      if (value is OverlayShow) {
        if (timer != null) timer!.cancel();

        ref.read(_show.notifier).update((state) => true);
        ref.read(_animIn.notifier).update((state) => true);
      }
      if (value is OverlayHide) {
        ref.read(_animIn.notifier).update((state) => false);

        timer = Timer(const Duration(milliseconds: 200), () {
          ref.read(_show.notifier).update((state) => false);
        });
      }
    });
  }
}

final _ctrlProvider = Provider((ref) => _Ctrl(ref));
final _show = StateProvider((ref) => false);
final _animIn = StateProvider((ref) => false);

class OverlayWidget extends ConsumerWidget {
  const OverlayWidget() : super(key: const Key('s_overlay'));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_ctrlProvider);

    return Offstage(
      offstage: !ref.watch(_show),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: ref.watch(_animIn) ? 1 : 0,
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: const Stack(
            fit: StackFit.loose,
            children: [
              OverlayAlert(),
            ],
          ),
        ),
      ),
    );
  }
}
