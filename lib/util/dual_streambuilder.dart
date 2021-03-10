import 'package:flutter/material.dart';

typedef DualAsyncWidgetBuilder<A, B> = Widget Function(BuildContext context,
    AsyncSnapshot<A> snapshotA, AsyncSnapshot<B> snapshotB);

class DualStreamBuilder<A, B> extends StatelessWidget {
  final Stream<A> streamA;
  final Stream<B> streamB;
  final A? initialDataA;
  final B? initialDataB;
  final DualAsyncWidgetBuilder<A, B> builder;

  DualStreamBuilder({
    required this.streamA,
    required this.streamB,
    this.initialDataB,
    this.initialDataA,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<A>(
      stream: streamA,
      initialData: initialDataA,
      builder: (_, snapshotA) {
        return StreamBuilder<B>(
          stream: streamB,
          initialData: initialDataB,
          builder: (_, snapshotB) {
            return builder(context, snapshotA, snapshotB);
          },
        );
      },
    );
  }
}
