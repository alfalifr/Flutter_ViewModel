

import 'package:viewmodel/view_model.dart';
import 'package:flutter/material.dart';

import 'expirable.dart';
import 'live_data.dart';

class ViewModelMultiObserver<Vm extends ViewModel> extends StatefulWidget {
  final List<LiveData Function(Vm)> liveDataGetters;

  /// [List] in this lambda parameter has elements that returned by [liveDataGetters].
  /// The element order of [List] is same as element order of [liveDataGetters].
  final Widget Function(BuildContext, List) builder;

  /// [List] in this lambda parameter has same property as [builder]'s.
  final bool Function(List)? predicate;
  final bool distinctUntilChanged;

  ViewModelMultiObserver({
    required this.liveDataGetters,
    required this.builder,
    this.predicate,
    this.distinctUntilChanged = false,
  });

  @override
  _ViewModelMultiObserverState<Vm> createState() => _ViewModelMultiObserverState<Vm>(
    liveDataGetters: liveDataGetters,
    builder: builder,
    predicate: predicate,
    distinctUntilChanged: distinctUntilChanged,
  );

}

class _ViewModelMultiObserverState<Vm extends ViewModel>
    extends State<ViewModelMultiObserver<Vm>>
    implements Expirable
{
  final List<LiveData Function(Vm)> liveDataGetters;

  /// [List] in this lambda parameter has elements that returned by [liveDataGetters].
  /// The element order of [List] is same as element order of [liveDataGetters].
  final Widget Function(BuildContext, List) builder;

  /// [List] in this lambda parameter has same property as [builder]'s.
  final bool Function(List)? predicate;
  final bool distinctUntilChanged;

  List<LiveData>? liveDatas;
  List? currentDatas;

  _ViewModelMultiObserverState({
    required this.liveDataGetters,
    required this.builder,
    this.predicate,
    required this.distinctUntilChanged,
  });

  bool _isActive = true;
  @override
  bool get isActive => _isActive;

  @override
  void dispose(){
    _isActive = false;
    super.dispose();
    liveDatas = null;
    currentDatas = null;
  }

  @override
  Widget build(BuildContext context) {
    if(liveDatas == null) {
      final vm = ViewModelProvider.of<Vm>(context);

      liveDatas = [];
      currentDatas = List.generate(liveDataGetters.length, (index) => null);

      for(int i = 0; i < liveDataGetters.length; i++) {
        final i2 = i;
        final getter = liveDataGetters[i];
        final liveData = getter(vm);
        liveDatas!.add(liveData);
        liveData.observe(this, (data) {
          currentDatas![i2] = data;
          if(predicate == null || predicate!(currentDatas!)) {
            setState(() {});
          }
        },
          distinctUntilChanged: distinctUntilChanged,
        );
      }
    }
    return builder(context, currentDatas!);
  }
}