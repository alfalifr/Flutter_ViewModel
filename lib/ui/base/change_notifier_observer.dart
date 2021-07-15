import 'package:flutter/cupertino.dart';

class ChangeNotifObserver extends StatefulWidget {
  final ChangeNotifier notifier;

  /// This will be called when [notifier] notifies change.
  /// However, when [initChild] is null, this [builder] can also be called
  /// in initial build although [notifier] hasn't yet notifies any change.
  final Widget Function(BuildContext) builder;
  final Widget? initChild;
  final bool isNotifierOwner;

  ChangeNotifObserver({
    required this.notifier,
    required this.builder,
    this.initChild,
    this.isNotifierOwner = false,
  });

  @override
  _ChangeNotifObserverState createState() => _ChangeNotifObserverState(
    notifier: notifier,
    builder: builder,
    initChild: initChild,
    isNotifierOwner: isNotifierOwner,
  );
}


class _ChangeNotifObserverState extends State<ChangeNotifObserver> {
  final ChangeNotifier notifier;

  /// This will be called when [notifier] notifies change.
  /// However, when [initChild] is null, this [builder] can also be called
  /// in initial build although [notifier] hasn't yet notifies any change.
  final Widget Function(BuildContext) builder;
  Widget? initChild;
  final bool isNotifierOwner;

  late final void Function() onChange;

  _ChangeNotifObserverState({
    required this.notifier,
    required this.builder,
    required this.initChild,
    required this.isNotifierOwner,
  }) {
    onChange = () => setState((){});
    notifier.addListener(onChange);
  }

  @override
  Widget build(BuildContext context) {
     final widget = initChild ?? builder(context);
     initChild = null;
     return widget;
  }

  @override
  void dispose() {
    notifier.removeListener(onChange);
    if(isNotifierOwner) {
      notifier.dispose();
    }
    super.dispose();
  }
}