import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/repository/document.dart';
import 'package:location_tracking_app_demo/service/service_auth.dart';
import 'package:location_tracking_app_demo/state/state_model.dart';

class _StateVisitors extends StateNotifier<Map<String, Visitor>> {
  final StateNotifierProviderRef ref;

  _StateVisitors(this.ref) : super({}) {
    ref.read(documentProvider).visitorStream.listen((value) {
      final Map<String, Visitor> map = {};

      for (var item in value) {
        final id = item.id;
        final data = item.data;
        if (data == null) continue;

        map[id] = Visitor(
          id: id,
          beaconId: data['beaconId'] ?? '',
          roomId: data['roomId'] ?? '',
          name: data['name'] ?? '',
          manager: data['manager'] ?? '',
          property: data['property'] ?? '',
          isFirstTime: data['isFirstTime'] ?? true,
          isShowMessage: data['isShowMessage'] ?? false,
          isActive: data['isActive'] ?? true,
          createAt: data['createAt'] ?? DateTime(0),
          admissionAt: data['admissionAt'] ?? DateTime(0),
          exitAt: data['exitAt'] ?? DateTime(0),
          reserveFrom: data['reserveFrom'] ?? DateTime(0),
          note: data['note'] ?? '',
          beforeAnswers: (data['beforeAnswers'] ?? []).cast<int>(),
          afterAnswers: (data['afterAnswers'] ?? []).cast<int>(),
          attachments: (data['attachments'] ?? []).cast<String>(),
          attachmentUrls: data['attachment_urls'] ?? <String, String>{},
          status: data['status'] ?? 0,
        );
      }
      state = map;
    });

    ref.read(streamProvider).listen((value) {
      if (value is Signin) {
    ref.read(documentProvider).listenVisitorList();
      }
      if (value is TriedSignout) {
        state = {};
      }
    });
  }
}

final visitorsProvider = StateNotifierProvider<_StateVisitors, Map<String, Visitor>>((ref) {
  return _StateVisitors(ref);
});

// final reserveVisitorGroup = Provider((ref) {
//   final visitors = ref.watch(visitorsProvider);

//   final map = <String, List<Visitor>>{};
//   for (var item in visitors.values) {
//     if (!item.isActive) continue;
//     final label = DateFormat('yyyy-MM-dd').format(item.reserveFrom);
//     if (map[label] == null) map[label] = [];
//     map[label]!.add(item);
//   }

//   // FIXME: reserveFromでsortする
//   map.forEach((key, value) {
//     value.sort((a, b) {
//       return a.reserveFrom.compareTo(b.reserveFrom);
//     });
//     map[key] = value;
//   });
//   return map;
// });

final visitorProvider = Provider.family<Visitor, String>((ref, id) {
  final visitors = ref.watch(visitorsProvider);
  return visitors[id] ?? Visitor.empty();
});

final visitorHistory = Provider.family((ref, String dateTimeString) {
  final dateTime = DateTime.parse(dateTimeString);
  ref.read(documentProvider).listenVisitorHistory(dateTime: dateTime);

  final visitors = ref.watch(visitorsProvider).values.where((element) {
    final isActive = element.isActive;
    final admissionAt = element.admissionAt;

    return isActive == false &&
        dateTime.compareTo(admissionAt) <= 0 &&
        dateTime.copyWith(month: dateTime.month + 1).compareTo(admissionAt) == 1;
  }).toList();

  return visitors..sort((a, b) => a.admissionAt.compareTo(b.admissionAt));
});
