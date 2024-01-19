import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';

const appDefaultRootPath = '';

class RouteLabel {
  static const login = 'login';
  // static const unavailable = 'unavailable';
  static const visitors = 'visitors';
  static const visitorsTrackedLocation = 'visitorsTrackedLocation';
}

const _separator = '|';

// TODO: いずれparamsをクラスで表現できるように変更する
@immutable
abstract class RouteParams {
  Map<String, dynamic> get data;

  @override
  String toString() {
    return json.encode(data);
  }
}

@immutable
class RouteSegment {
  final String name;
  final Map<String, dynamic>? params;
  final bool fullscreenDialog;
  const RouteSegment(
    this.name, {
    this.params,
    this.fullscreenDialog = false,
  });

  Page build(Widget child, {bool? fullscreenDialog}) {
    return MaterialPage(
      child: child,
      arguments: this,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
    );
  }

  static RouteSegment fromString(String value) {
    final arr = value.split(_separator);
    final name = arr[0];
    final params = arr.length > 1 ? json.decode(arr[1]) : null;
    return RouteSegment(name, params: params);
  }

  @override
  String toString() {
    if (params == null) return name;
    return '$name$_separator${json.encode(params!)}';
  }
}

class RouterObject {
  final Uri uri;
  final List<RouteSegment> segments = [];
  bool async = false; // FIXME: RouterServiceにより変更される可能性がある

  RouterObject({required this.uri}) {
    for (var item in uri.pathSegments) {
      segments.add(RouteSegment.fromString(item));
    }
  }

  Map<String, dynamic> get params => segments.last.params ?? {};
  List<String> get pathSegments => segments.map((e) => e.name).toList();

  bool contains(String name) => pathSegments.contains(name);
}

@immutable
class RouterProcessEvent extends StreamProcessEvent {
  static RouterObject _currentState = RouterObject(uri: Uri());
  static RouterObject get currentState => _currentState;

  final RouterObject state;
  final RouterObject nextState;

  RouterProcessEvent(Uri uri)
      : state = RouterObject(uri: RouterChangedEvent.currentState.uri),
        nextState = RouterObject(uri: uri) {
    _currentState = state;
  }

  bool get isAsync => currentState.async;

  static RouterProcessEvent pop({int count = 1}) {
    final uri = RouterChangedEvent.currentState.uri;
    final segments = [...uri.pathSegments];
    for (var i = 0; i < count; i++) {
      if (segments.isNotEmpty) segments.removeLast();
    }

    if (segments.isNotEmpty) {
      return RouterProcessEvent(Uri(
        path: '/${segments.map((e) => e.toString()).join('/')}',
      ));
    } else {
      return RouterProcessEvent(Uri(
        path: appDefaultRootPath,
      ));
    }
  }

  static String segmentsToPath(List<RouteSegment> segments) => '/${segments.map((e) => e.toString()).join('/')}';
}

class RouterChangedEvent extends StreamChangedEvent {
  static RouterObject _currentState = RouterObject(uri: Uri());
  static RouterObject get currentState => _currentState;
  static String get lastRouteLabel => currentState.segments.last.name;
  static bool frontmost(String label) => label == lastRouteLabel;

  final RouterObject state;

  RouterChangedEvent(super.process) : state = RouterObject(uri: (process as RouterProcessEvent).nextState.uri) {
    _currentState = state;
  }
}
