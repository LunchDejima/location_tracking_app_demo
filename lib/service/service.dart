import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/repository/auth.dart';
import 'package:location_tracking_app_demo/repository/document.dart';
import 'package:location_tracking_app_demo/service/service_auth.dart';
import 'package:location_tracking_app_demo/service/service_system.dart';

final initService = Provider((ref) {
  final auth = ref.read(authProvider);
  final document = ref.read(documentProvider);
  final stream = ref.read(streamProvider);

  ServiceSystem(stream);
  ServiceAuth(stream, auth: auth, document: document);
  // ServiceRoom(stream, document: document);
  // ServiceVisitor(stream, document: document);
});