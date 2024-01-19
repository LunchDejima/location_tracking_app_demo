import 'package:flutter/material.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/repository/auth.dart';
import 'package:location_tracking_app_demo/repository/document.dart';

@immutable
class InitializeAuth extends StreamProcessEvent {}

@immutable
class InitializedAuth extends StreamChangedEvent {
  InitializedAuth(super.process);
}

@immutable
class TrySignin extends StreamProcessEvent {
  final String email;
  final String password;
  TrySignin({
    required this.email,
    required this.password,
    super.key,
  });
}

@immutable
class TriedSignin extends StreamChangedEvent {
  TriedSignin(super.process);
}

@immutable
class TrySignout extends StreamProcessEvent {
  TrySignout({super.key});
}

@immutable
class TriedSignout extends StreamChangedEvent {
  TriedSignout(super.process);
}

@immutable
class Signin extends StreamEvent {
  final String uid;
  final String email;
  final bool isAnonymous;
  final bool emailVerified;
  final bool isAdmin;
  Signin({
    required this.uid,
    required this.email,
    required this.isAnonymous,
    required this.emailVerified,
    required this.isAdmin,
  });
}

@immutable
class Signout extends StreamEvent {}

class ServiceAuth extends StreamAsyncServiceBase {
  final Document document;
  final Auth auth;
  
  ServiceAuth(
    super.stream, {
    required this.auth,
    required this.document,
  });

  @override
  Stream<StreamChangedEvent> mapProcessToChanged(StreamProcessEvent process) async* {
    if (process is InitializeAuth) yield* _initialize(process);
    if (process is TrySignin) yield* _signin(process);
    if (process is TrySignout) yield* _signout(process);
  }

  bool isSinin = false;
  Stream<InitializedAuth> _initialize(InitializeAuth process) async* {
    
    auth.authStream.listen((event) {
      if (event == null) {
        isSinin = false;
        stream.add(Signout());
        return;
      }

      final data = event.data;
      if (!isSinin) {
        document.awake();
        stream.add(Signin(
          uid: event.uid,
          email: data['email'] ?? '',
          isAnonymous: false,
          emailVerified: data['emailVerified'] ?? false,
          isAdmin: data['admin'] ?? false,
        ));
      }
    });

    auth.init();
    yield InitializedAuth(process);
  }

  Stream<TriedSignin> _signin(TrySignin process) async* {
    await document.close();
    await auth.signinWithEmailAndPassword(
      email: process.email,
      password: process.password,
    );
    yield TriedSignin(process);
  }

   Stream<TriedSignout> _signout(TrySignout process) async* {
    await document.close();
    await auth.signout();
    yield TriedSignout(process);
  }
}
