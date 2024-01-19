import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:location_tracking_app_demo/state/state_visitor.dart';

// final _stream = Provider.autoDispose((ref) {
//   final sub = ref.read(streamProvider).listen((value) {
//     if (value is RouterChangedEvent && RouterChangedEvent.frontmost(RouteLabel.visitors)) {
//       final d = value.state.segments.last.params?['d'] ?? '1900-01';
//       ref.read(_dateTime.notifier).update((state) => DateTime.parse('$d-01'));
//     }
//   });
//   ref.onDispose(() {
//     sub.cancel();
//   });
// });

final _dateTime = StateProvider.autoDispose((ref) => DateTime.now().copyWith(
      day: 1,
      hour: 0,
      minute: 0,
      millisecond: 0,
      microsecond: 0,
    ));

class SVisitors extends ConsumerWidget {
  const SVisitors({super.key = const Key('s_visitors')});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(_stream);

    final theme = Theme.of(context);

    // final dateTime = ref.watch(_dateTime);
    final visitors = ref.watch(visitorsProvider);


    final tableHeader = ['受付日時', '終了日時', '氏名', '担当販売員', '物件名', 'ビーコンID', '商談部屋', ''];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Column(children: [Text('Visitors')]),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('来場者数', style: theme.textTheme.titleMedium),
                  const SizedBox(width: 10),
                  Text(
                    '${visitors.length}',
                    style: theme.textTheme.displayMedium!.copyWith(
                      color: theme.colorScheme.primaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Table(
                border: TableBorder.all(color: theme.colorScheme.outline),
                columnWidths: const <int, TableColumnWidth>{
                  // 0: IntrinsicColumnWidth(),
                  // 1: FlexColumnWidth(),
                  // 2: FixedColumnWidth(64),
                  // 0: FixedColumnWidth(150),
                  // 1: FlexColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: tableHeader.map((e) {
                      return TableCell(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: theme.colorScheme.surface,
                          child: Text(e, textAlign: TextAlign.center),
                        ),
                      );
                    }).toList(),
                  ),
                  ...visitors.values.map((e) {
                    return TableRow(
                      decoration: const BoxDecoration(
                        border: Border.symmetric(vertical: BorderSide.none),
                        // color: Colors.amber
                      ),
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(e.admissionAt),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(e.exitAt),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(e.name),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(e.manager),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(e.property),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(e.beaconId),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(e.roomId),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              onPressed: () {
                                // Navigator.push(context, MaterialPageRoute(builder: builder));
                                // ref.read(routePush)([
                                //   RouteSegment(RouteLabel.visitorDetail, params: {'id': e.id})
                                // ]);
                              },
                              child: const Text('詳細'),
                            ),
                          ),
                        ),
                      ],
                    );
                  })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
