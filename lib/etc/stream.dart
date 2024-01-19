import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/etc/logger.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

final streamProvider = Provider((ref) => PublishSubject<StreamEvent>(sync: false));

@immutable
class StreamEvent {
  StreamEvent({String? key}) : _key = key ?? DateTime.now().microsecondsSinceEpoch.toString();
  final String _key;
  String get key => _key;
}

@immutable
class StreamProcessEvent extends StreamEvent {
  StreamProcessEvent({super.key});
}

@immutable
class StreamChangedEvent extends StreamEvent {
  final StreamProcessEvent process;
  StreamChangedEvent(this.process) : super(key: process.key);
}

@immutable
class StreamFailedEvent extends StreamChangedEvent {
  final dynamic error;
  StreamFailedEvent(super.process, {this.error});
}

@immutable
class StreamTimeoutEvent extends StreamFailedEvent {
  StreamTimeoutEvent(super.process, {super.error});
}

abstract class SagaBase<T extends StreamProcessEvent> {
  static final mutex = Mutex();
  final PublishSubject<StreamEvent> stream;

  SagaBase(this.stream) {
    stream.whereType<T>().listen(onEvent);
  }
  void onEvent(T event);
  void dispose() {}
}

abstract class StreamAsyncServiceBase<T extends StreamProcessEvent, R extends StreamChangedEvent> {
  final PublishSubject<StreamEvent> stream;
  StreamAsyncServiceBase(this.stream) {
    stream.whereType<T>().asyncExpand<R>((process) {
      return mapProcessToChanged(process).handleError((error) {
        logger.severe(error);
        if (error is TimeoutException) {
          stream.add(StreamTimeoutEvent(process, error: error));
        } else {
          stream.add(StreamFailedEvent(process, error: error));
        }
      });
    }).listen(
      (changed) {
        stream.add(changed);
      },
      onError: (error) {
        logger.severe('serviceBase $error');
      },
      cancelOnError: false,
    );
  }

  Stream<R> mapProcessToChanged(T process);
}