import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/subjects.dart';

final documentProvider = Provider<Document>((ref) {
  return DocumentFire(
    store: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

abstract class Document {
  void awake();
  Future<void> close();

  final visitorStream = PublishSubject<List<DocumentData>>();
  void listenVisitorList();

  void listenVisitorHistory({required DateTime dateTime});
}

@immutable
class DocumentData {
  final String id;
  final Map<String, dynamic>? data;
  const DocumentData({required this.id, this.data});
}

class DocumentFire extends Document {
  final FirebaseFirestore store;
  final FirebaseStorage storage;

  DocumentFire({
    required this.store,
    required this.storage,
  }) {
    // if (!isTesting) {
    //   if (kIsWeb) {
    //     /*
    //     store.enablePersistence(
    //       const PersistenceSettings(synchronizeTabs: true),
    //     );
    //     */
    //   } else {
    //     store.settings = const Settings(
    //       persistenceEnabled: true,
    //       cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    //     );
    //   }
    // }
  }

  Map<String, StreamSubscription> _subs = {};

  @override
  void awake() {
    _subs = {};
  }

  @override
  Future<void> close() async {
    await Future.wait(_subs.values.map((sub) => sub.cancel()));
  }

  static const _dateTimeParams = [
    'createAt',
    'updateAt',
    'admissionAt',
    'exitAt',
    'reserveFrom',
    'reserveTo',
    'timestamp'
  ];
  // static const _rooms = 'rooms';
  // static const _beacons = 'beacons';
  static const _visitors = 'visitors';
  // static const _visitorActions = 'actions';
  // static const _visitorRoomActions = 'roomActions';

  Future<DocumentData> _getDaoData(DocumentSnapshot<Map<String, dynamic>> snap) async {
    final id = snap.id;
    final data = snap.data();
    if (data == null) return DocumentData(id: id);

    for (var item in _dateTimeParams) {
      if (data[item] != null) {
        data[item] = (data[item] as Timestamp).toDate();
      }
    }

    final List attachments = data['attachments'] ?? [];
    if (attachments.isNotEmpty) {
      final storageRef = storage.ref();
      final map = <String, String>{};
      for (var value in attachments) {
        map[value] = await storageRef.child(value).getDownloadURL();
      }
      data['attachment_urls'] = map;
    }


    return DocumentData(id: id, data: data);
  }

  @override
  void listenVisitorList() async {
    if (_subs[_visitors] != null) return;

    final ref = store.collection(_visitors);
    final stream = ref.snapshots();
    _subs[_visitors] = stream.distinct().listen((event) async {
      final list = (await Future.wait(event.docs.map((e) async {
        return await _getDaoData(e);
      })));
      visitorStream.add(list);
    });
  }


  @override
  void listenVisitorHistory({required DateTime dateTime}) {
    final key = dateTime.toIso8601String();
    if (_subs[key] != null) return;

    final ref = store.collection(_visitors);
    // .where('isActive', isEqualTo: false)
    // .where('admissionAt', isGreaterThanOrEqualTo: dateTime);
    // .where('admissionAt', isLessThan: dateTime.copyWith(month: dateTime.month + 1));
    final stream = ref.snapshots();
    _subs[key] = stream.distinct().listen((event) async {
      final list = (await Future.wait(event.docs.map((e) async {
        return await _getDaoData(e);
      })));
      visitorStream.add(list);
    });
  }
}
