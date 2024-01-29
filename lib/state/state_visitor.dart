import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/repository/document.dart';
import 'package:location_tracking_app_demo/repository/strage.dart';
import 'package:location_tracking_app_demo/service/service_auth.dart';
import 'package:location_tracking_app_demo/state/state_model.dart';

class _StateVisitors extends StateNotifier<Map<String, Visitor>> {
  final StateNotifierProviderRef ref;

  _StateVisitors(this.ref) : super({}) {
    ref.read(documentProvider).visitorStream.listen((value) async {
      final Map<String, Visitor> map = {};

      for (var item in value) {
        final id = item.id;
        final data = item.data;
        if (data == null) continue;
        final recordData = await ref.read(strageProvider).getRecord(id: id);
        late final List<String> beaconInfos;
        if (recordData.isEmpty) {
          continue;
        } else {
          final re = RegExp(',|\n');
          beaconInfos = recordData.split(re).sublist(9);
        }

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
          beaconInfos: beaconInfos,
        );
        break;
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

final visitorProvider = Provider.family<Visitor, String>((ref, id) {
  final visitors = ref.watch(visitorsProvider);
  return visitors[id] ?? Visitor.empty();
});
