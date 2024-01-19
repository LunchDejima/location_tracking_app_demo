import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
final authProvider = Provider<Auth>((ref) {
  return AuthFire(auth: FirebaseAuth.instance);
});

abstract class Auth {
  final authStream = PublishSubject<AuthData?>();
  void init();
  Future<void> signinWithEmailAndPassword({required String email, required String password});
  Future<void> signout();
}

@immutable
class AuthData {
  final String uid;
  final Map<String, dynamic> data;
  const AuthData({required this.uid, required this.data});
}


class AuthFire extends Auth {
  final FirebaseAuth auth;
  AuthFire({required this.auth});
  StreamSubscription? _subAuth;

  @override
  void init() {
    if (_subAuth != null) return;

    /**
     * FIXME: Webだとhot reloadのたびに呼ばれる回数が増えていくため、以下のdistinct処理を入れる
     * 1. 前回取得した値と同じだった場合は、distinct（signout時のnullが該当する）
     * 2. 前回取得したUser.uidが同じ場合だったらdistinct
     */
    final stream = auth.userChanges();
    _subAuth = stream.distinct((pre, next) {
      if (pre == next) {
        return true;
      } else {
        return pre?.uid == next?.uid;
      }
    }).asyncMap<AuthData?>((event) async {
      if (event == null) return null;

      // FIXME: test case
      // if (isTesting) {
      //   return AuthData(uid: event.uid, data: {
      //     'email': event.email,
      //     'emailVerified': event.emailVerified,
      //     'isAnonymous': event.isAnonymous,
      //     'admin': false,
      //   });
      // }

      final token = await event.getIdTokenResult(true);
      final claims = token.claims ?? {'status': '', 'admin': false};

      return AuthData(
        uid: event.uid,
        data: {
          'email': event.email,
          'emailVerified': event.emailVerified,
          'isAnonymous': event.isAnonymous,
          'admin': claims['admin'],
        },
      );
    }).listen((event) {
      authStream.add(event);
    }, onError: (e) {
      print(e.toString());
    });
  }

  @override
  Future<void> signinWithEmailAndPassword({required String email, required String password}) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signout() {
    return auth.signOut();
  }
}
