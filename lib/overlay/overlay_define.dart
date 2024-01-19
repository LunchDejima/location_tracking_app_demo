import 'package:flutter/material.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';

@immutable
class OverlayEvent extends StreamEvent {}

@immutable
class OverlayShow extends OverlayEvent {}

@immutable
class OverlayHide extends OverlayEvent {}

@immutable
class AlertOverlayShow extends OverlayShow {
  final Widget Function(BuildContext context) builder;
  final VoidCallback? callback;
  AlertOverlayShow({required this.builder, this.callback});
}

@immutable
class AlertOverlayHide extends OverlayHide {}

