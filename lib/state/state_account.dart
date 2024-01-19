import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracking_app_demo/repository/auth.dart';
import 'package:location_tracking_app_demo/state/state_model.dart';

/**
 * StateAccount
 */
class _StateAccount extends StateNotifier<Account> {
  final StateNotifierProviderRef ref;
  _StateAccount(this.ref) : super(const Account(uid: '', email: '')) {
    ref.read(authProvider).authStream.listen((event) {
      if (event == null) {
        state = const Account(uid: '', email: '');
        return;
      }

      final uid = event.uid;
      final data = event.data;
      
      state = Account(
        uid: uid,
        email: data['email'] ?? '',
        emailVerified: data['emailVerified'] ?? false,
        isAdmin: data['admin'] ?? false,
        isAnonymous: data['isAnonymous'] ?? false,
      );
    });
  }
}

final accountProvider = StateNotifierProvider<_StateAccount, Account>((ref) {
  return _StateAccount(ref);
});

final stateUid = Provider((ref) {
  final account = ref.watch(accountProvider);
  return account.uid;
});
