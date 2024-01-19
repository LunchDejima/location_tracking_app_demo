import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/overlay/overlay.dart';
import 'package:location_tracking_app_demo/overlay/overlay_define.dart';
import 'package:rxdart/rxdart.dart';

class _Ctrl {
  final ProviderRef ref;
  Widget Function(BuildContext context) builder = (_) => const SizedBox();
  VoidCallback? callback;

  _Ctrl(this.ref) {
    Timer? timer;

    ref.read(streamProvider).whereType<OverlayEvent>().distinct().listen((value) {
      if (value is AlertOverlayShow) {
        if (timer != null) timer!.cancel();

        builder = value.builder;
        callback = value.callback;
        ref.read(_show.notifier).update((state) => true);
        ref.read(_animIn.notifier).update((state) => true);
      }
      if (value is AlertOverlayHide) {
        ref.read(_animIn.notifier).update((state) => false);

        timer = Timer(const Duration(milliseconds: 200), () {
          ref.read(_show.notifier).update((state) => false);
        });
      }
    });
  }

  void close() {
    // FIXME: callback functionに対応する
    if (callback != null) callback!();
    callback = null;
    ref.read(hideAlert)();
  }
}

final _ctrlProvider = Provider((ref) => _Ctrl(ref));
final _show = StateProvider((ref) => false);
final _animIn = StateProvider((ref) => false);

class OverlayAlert extends ConsumerWidget {
  const OverlayAlert() : super(key: const Key('s_overlay_alert'));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ctrl = ref.read(_ctrlProvider);

    return Offstage(
      offstage: !ref.watch(_show),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: ref.watch(_animIn) ? 1 : 0,
        child: Center(
          child: Card(
            elevation: 1.0,
            color: theme.colorScheme.surfaceVariant,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Alert'),
                const SizedBox(height: 20),
                //
                ctrl.builder(context),
                //
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        ctrl.close();
                      },
                      child: Text('閉じる'),
                    )
                  ],
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

