import 'package:flutter/foundation.dart';

@immutable
class Account {
  final String uid;
  final String email;

  final bool emailVerified;
  final bool isAdmin;
  final bool isAnonymous;

  const Account({
    required this.uid,
    required this.email,
    this.emailVerified = false,
    this.isAdmin = false,
    this.isAnonymous = false,
  });
}

@immutable
class Visitor {
  final String id;
  final String beaconId;
  final String roomId;

  final String name;
  final String manager;
  final String property;
  final bool isFirstTime;
  final bool isShowMessage;
  final bool isActive;

  final DateTime createAt;
  final DateTime admissionAt;
  final DateTime exitAt;
  final DateTime reserveFrom;

  final String note;

  // TODO: アンケート
  final List<int> beforeAnswers;
  final List<int> afterAnswers;
  final List<String> attachments; 
  final Map<String, String> attachmentUrls; 

  final int status;

  const Visitor({
    required this.id,
    required this.beaconId,
    required this.roomId,
    required this.name,
    required this.manager,
    required this.property,
    required this.isFirstTime,
    required this.isShowMessage,
    required this.isActive,
    required this.createAt,
    required this.admissionAt,
    required this.exitAt,
    required this.reserveFrom,
    required this.note,
    required this.beforeAnswers,
    required this.afterAnswers,
    required this.attachments,
    required this.attachmentUrls,
    required this.status,
  });

  static Visitor empty() {
    return Visitor(
      id: '',
      beaconId: '',
      roomId: '',
      name: '',
      manager: '',
      property: '',
      isFirstTime: true,
      isShowMessage: false,
      isActive: true,
      createAt: DateTime.now(),
      admissionAt: DateTime.now(),
      exitAt: DateTime.now(),
      reserveFrom: DateTime.now(),
      note: '',
      beforeAnswers: const [],
      afterAnswers: const [],
      attachments: const [],
      attachmentUrls: const {},
      status: 0, //0:初期状態, 1: 入場済み, 100:退出済み, 101:位置情報記録済み, 102: 位置情報検出できない場合
    );
  }

  bool get isDoing =>  status > 0 && status < 100;
  // getBeforeAnswer(int index) {
  //   if (beforeAnswers.length > index) {
  //     return answers1[beforeAnswers[index]];
  //   } else {
  //     return '';
  //   }
  // }
  // getAfterAnswer(int index) {
  //   if (afterAnswers.length > index) {
  //     return answers2[afterAnswers[index]];
  //   } else {
  //     return '';
  //   }
  // }
}
