import 'dart:async';
import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/etc/logger.dart';

final strageProvider = Provider<Strage>((ref) {
  return StrageFire(
    storage: FirebaseStorage.instance,
  );
});

abstract class Strage {
  Future<String> getRecord({required String id});
}

class StrageFire extends Strage {
  final FirebaseStorage storage;

  StrageFire({required this.storage});

  static const _records = 'records';

  @override
  Future<String> getRecord({required String id}) async {
    final ref = storage.ref();
    try {
      final data = await ref.child('$_records/$id.csv').getData();
      final decodedData = utf8.decode(data ?? []);
      return decodedData;
    } catch (e) {
      logger.info(e);
      return '';
    }
  }
}
