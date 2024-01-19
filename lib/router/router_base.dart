import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location_tracking_app_demo/etc/logger.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/router/router_define.dart';
import 'package:location_tracking_app_demo/router/router_not_found.dart';
import 'package:rxdart/rxdart.dart';

class AppRouteInformationParser extends RouteInformationParser<RouterObject> {
  // FIXME: MaterialApp.routerに設定すれば、Routerごとには必要なさそう
  const AppRouteInformationParser() : super();

  @override
  Future<RouterObject> parseRouteInformation(RouteInformation routeInformation) async {
    // FIXME: OSによるroute変更の処理が行われたときに呼ばれる
    final uri = routeInformation.uri;
    if (uri.pathSegments.isEmpty) {
      return RouterObject(uri: Uri(path: appDefaultRootPath));
    }
    return RouterObject(uri: uri);
  }

  @override
  RouteInformation? restoreRouteInformation(RouterObject configuration) {
    // FIXME: delegateのcallbackによりurlが変更された際に呼ばれる
    /*
    if (configuration.path == '/restore') {
      return const RouteInformation(location: '/restore2');
    }
    */
    return RouteInformation(uri: configuration.uri);
  }
}

class AppRouterDelegate extends RouterDelegate<RouterObject> with PopNavigatorRouterDelegateMixin {
  final PublishSubject<StreamEvent> stream;
  final List<Page> Function(RouterObject state) generatePages;
  late StreamSubscription _sub;
  VoidCallback? _callback;

  AppRouterDelegate({
    required this.stream,
    required this.generatePages,
  }) {
    // FIXME: RouterProcessEventをチェックする必要ない
    _sub = stream.whereType<RouterChangedEvent>().listen((value) {
      // TODO: delegateが登録されている分だけ、呼ばれてしまう。システム的には一度登録すれば良いはず。
      if (_callback == null) return;
      _callback!();
    });
  }

  // FIXME:  call this sometime to keep from leaking listeners
  void dispose() {
    _sub.cancel();
  }

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void addListener(VoidCallback listener) {
    _callback = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    // FIXME: viewから外れると呼ばれる
    _callback = null;
  }

  @override
  Future<bool> popRoute() async {
    // TODO: Whether Router.backButtonDispatcher is enabled
    logger.info('--------popRoute----------');
    // return super.popRoute();
    // TODO: android対策として、backボタンを無効にしたが、本当にそれで良いのかちゃんと考える
    return true;
  }

  @override
  RouterObject? get currentConfiguration {
    // FIXME: callbackの後に呼ばれる
    return RouterChangedEvent.currentState;
  }

  @override
  Future<void> setNewRoutePath(RouterObject configuration) async {
    // FIXME: OSによるRoute処理の後に呼ばれる
    // TODO: deep linkとの関連性を調べる
    stream.add(RouterProcessEvent(configuration.uri));
  }

  @override
  Future<void> setRestoredRoutePath(RouterObject configuration) {
    logger.info('-----setRestoredRoutePath------');
    return super.setRestoredRoutePath(configuration);
  }

  @override
  Widget build(BuildContext context) {
    final _pages = generatePages(currentConfiguration!);
    // FIXME: 表示するpageがない場合はnot found.
    if (_pages.isEmpty) _pages.add(const MaterialPage(child: RouterNotFoundWidget()));

    return Navigator(
      key: navigatorKey,
      pages: _pages,
      onPopPage: (route, result) {
        stream.add(RouterProcessEvent.pop());
        return route.didPop(result);
      },
    );
  }
}