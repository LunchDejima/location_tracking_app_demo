import 'package:location_tracking_app_demo/etc/stream.dart';
import 'package:location_tracking_app_demo/router/router_define.dart';

class RouterService extends StreamAsyncServiceBase<RouterProcessEvent, RouterChangedEvent> {
  RouterService(super.stream);

  @override
  Stream<RouterChangedEvent> mapProcessToChanged(RouterProcessEvent process) async* {
    // TODO: URLごとにFutureが必要な処理が必要な場合に追加する
    /*
    if (process.nextState.contains(RouteLabel.login)) {
      yield* _login(process);
    }
    */
    yield RouterChangedEvent(process);
  }

  Stream<RouterChangedEvent> _login(RouterProcessEvent process) async* {
    process.state.async = true;
    // await Future.delayed(const Duration(milliseconds: 1000));
  }
}
