import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/router/router_base.dart';
import 'package:location_tracking_app_demo/router/router_define.dart';
import 'package:location_tracking_app_demo/router/router_service.dart';
import 'package:location_tracking_app_demo/service/service_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final initRouter = Provider((ref) {
  ref.read(route);

  final stream = ref.read(streamProvider);
  RouterService(stream);

  stream.listen((value) {
    if (value is Signin) {
      ref.read(routeWithSegments)(const [RouteSegment(RouteLabel.visitors)]);
    }
    if (value is Signout) {
      ref.read(routeWithSegments)(const [
        RouteSegment(RouteLabel.login),
      ]);
    }
  });
});

final appRouteInformationParser = Provider((ref) => const AppRouteInformationParser());
final appRouterGeneratePages = Provider((ref) {
  return (List<Page> Function(RouterObject state) generatePages) {
    return AppRouterDelegate(stream: ref.read(streamProvider), generatePages: generatePages);
  };
});

var _process = RouterProcessEvent(RouterChangedEvent.currentState.uri);
final route = Provider<void Function(Uri)>((ref) {
  ref.read(streamProvider).whereType<RouterProcessEvent>().listen((event) => _process = event);

  return (Uri uri) {
    if (_process.nextState.uri.toString() == uri.toString()) return;
    ref.read(streamProvider).add(RouterProcessEvent(uri));
  };
});

final routeWithPath = Provider<void Function(String)>((ref) {
  return (String value) {
    ref.read(route)(Uri(path: value));
  };
});

final routeWithSegments = Provider<void Function(List<RouteSegment>)>((ref) {
  return (List<RouteSegment> value) {
    ref.read(route)(Uri(path: RouterProcessEvent.segmentsToPath(value)));
  };
});

final routePush = Provider<void Function(List<RouteSegment>)>((ref) {
  // FIXME: 複数pushできるようにしたい
  return (List<RouteSegment> segments) {
    ref.read(route)(Uri(
      path: '${RouterChangedEvent.currentState.uri.path}/${segments.map((e) => e.toString()).join('/')}',
    ));
  };
});

final routerSwap = Provider<void Function(RouteSegment)>((ref) {
  return (RouteSegment segment) {
    final segments = [...RouterChangedEvent.currentState.segments];
    segments.removeLast();
    segments.add(segment);
    ref.read(routeWithSegments)(segments);
  };
});

final routePop = Provider((ref) {
  return ({count = 1}) {
    ref.read(streamProvider).add(RouterProcessEvent.pop(count: count));
  };
});

final hasParent = Provider((ref) {
  return ({required String label, required String parent}) {
    final pathSegments = RouterChangedEvent.currentState.pathSegments;
    final index = pathSegments.indexOf(label);
    final parentIndex = pathSegments.indexOf(parent);

    if (index == -1 || parentIndex == -1) return false;
    return index > parentIndex;
  };
});
