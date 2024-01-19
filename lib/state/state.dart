import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/state/state_account.dart';
import 'package:location_tracking_app_demo/state/state_visitor.dart';

final initState = Provider((ref) {
  ref.read(accountProvider);
  ref.read(visitorsProvider);
});
