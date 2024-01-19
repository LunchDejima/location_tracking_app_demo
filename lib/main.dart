import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:location_tracking_app_demo/etc/logger.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/overlay/overlay.dart';
import 'package:location_tracking_app_demo/overlay/overlay_widget.dart';
import 'package:location_tracking_app_demo/overlay/progress.dart';
import 'package:location_tracking_app_demo/pages/login/login.dart';
import 'package:location_tracking_app_demo/pages/visitor/visitors.dart';
import 'package:location_tracking_app_demo/router/router.dart';
import 'package:location_tracking_app_demo/router/router_define.dart';
import 'package:location_tracking_app_demo/saga/saga.dart';
import 'package:location_tracking_app_demo/saga/saga_initialize.dart';
import 'package:location_tracking_app_demo/service/service.dart';
import 'package:location_tracking_app_demo/state/state.dart';
import 'package:rxdart/rxdart.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  setupLogger();
  setUrlStrategy(PathUrlStrategy());

  // final beaconInfos = await importCsv();

  runApp(
    const ProviderScope(
      observers: [ProviderLogger()],
      child: AppWidget(
        // beaconInfos: beaconInfos,
      ),
    ),
  );
}

class _Ctrl {
  final ProviderRef ref;
  _Ctrl(this.ref) {
    ref.read(initOverlay);
    ref.read(initRouter);
    ref.read(initState);
    ref.read(initService);
    ref.read(initSaga);

    late StreamSubscription subRouter;
    subRouter = ref.read(streamProvider).whereType<RouterChangedEvent>().listen((event) {
      // FIXME: navigator 2.0 call current url first. have to wait first event.
      subRouter.cancel();
      ref.read(streamProvider).add(DoInitialize());
    });

    late StreamSubscription subState;
    subState = ref.read(streamProvider).whereType<DoneInitialize>().listen((event) {
      subState.cancel();
      ref.read(_initializedProvider.notifier).update((state) => true);
    });
  }
}

final _ctrlProvider = Provider((ref) => _Ctrl(ref));
final _initializedProvider = StateProvider((ref) => false);

Future<List> importCsv() async {
  const path = 'assets/records_beacon.csv';
  final strings = await rootBundle.loadString(path);
  final re = RegExp(',|\n');
  final beaconInfos = strings.split(re).sublist(9);
  return beaconInfos;
}

class AppWidget extends ConsumerWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(_ctrlProvider);
    ref.watch(_initializedProvider);
    // ref.read(documentProvider);

    return MaterialApp.router(
      title: 'Location tracking app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routeInformationParser: ref.read(appRouteInformationParser),
      routerDelegate: ref.read(appRouterGeneratePages)((state) {
        return [
          MaterialPage(
            child: Stack(
              children: [
                Router(routerDelegate: ref.read(_routerDelegate)),
                // FIXME: overlay
                const OverlayWidget(),
                const ProgressWidget(),
              ],
            ),
          )
        ];
      }),
    );
  }
}

final _routerDelegate = Provider((ref) {
  return ref.read(appRouterGeneratePages)((state) {
    final initialzed = ref.read(_initializedProvider);
    print(initialzed);
    if (!initialzed) {
      // FIXME: before initialize
      return [const MaterialPage(child: Scaffold())];
    }

    final pages = <Page>[];
    for (var item in state.segments) {
      final name = item.name;
      if (name == RouteLabel.login) pages.add(item.build(const SLogin()));
      if (name == RouteLabel.visitors) pages.add(item.build(const SVisitors()));
      // if (name == RouteLabel.visitorsTrackedLocation) pages.add(item.build(const STrackedLocation()));
    }
    return pages;
  });
});
