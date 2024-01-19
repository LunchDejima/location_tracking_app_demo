import 'package:flutter/material.dart';

class RouterNotFoundWidget extends StatelessWidget {
  const RouterNotFoundWidget() : super(key: const Key('undefined'));

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('NOT FOUND...'),
      ),
    );
  }
}