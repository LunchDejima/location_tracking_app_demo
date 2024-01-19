import 'package:location_tracking_app_demo/etc/logger.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:flutter/material.dart';

@immutable
class InitializeSystem extends StreamProcessEvent {
  InitializeSystem({String? key}) : super(key: key);
}

@immutable
class InitializedSystem extends StreamChangedEvent {
  InitializedSystem(super.process);
}

@immutable
class ChangeLanguage extends StreamProcessEvent {
  final String locale;
  ChangeLanguage({required this.locale});
}
class ChangedLanguage extends StreamChangedEvent {
  ChangedLanguage(super.process);
}

class ServiceSystem extends StreamAsyncServiceBase with WidgetsBindingObserver {
  ServiceSystem(super.stream) {
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    logger.info('------ changed life cycle --------');
  }

  @override
  Stream<StreamChangedEvent> mapProcessToChanged(StreamProcessEvent process) async* {
    if (process is InitializeSystem) yield* _initialize(process);
  }

  Stream<InitializedSystem> _initialize(InitializeSystem process) async* {
    await Future.delayed(const Duration(seconds: 1));
    yield InitializedSystem(process);
  }
}
