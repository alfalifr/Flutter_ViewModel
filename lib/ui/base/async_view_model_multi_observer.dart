import 'package:viewmodel/ui/base/async_view_model_observer.dart';
import 'package:flutter/material.dart';

import 'async_vm.dart';
import 'expirable.dart';
import 'live_data.dart';
import 'view_model.dart';

/// [AsyncVmObserver] that has ability to observe to multiple [Vm].[LiveData].
class AsyncVmMultiObserver<Vm extends AsyncVm> extends StatefulWidget {
  final List<LiveData Function(Vm)> liveDataGetters;

  /// [List] in this lambda parameter has elements that returned by [liveDataGetters].
  /// The element order of [List] is same as element order of [liveDataGetters].
  final Widget Function(BuildContext, List) builder;

  /// [List] in this lambda parameter has same property as [builder]'s.
  final bool Function(List)? predicate;

  /// If it returns [Widget], it means the widget will be rebuilt using the returned [Widget].
  /// If it returns null, the old [Widget] will stay.
  final Widget? Function(BuildContext ctx, String key)? preAsyncBuilder;
  final bool distinctUntilChanged;

  AsyncVmMultiObserver({
    required this.liveDataGetters,
    required this.builder,
    this.predicate,
    this.preAsyncBuilder,
    this.distinctUntilChanged = false,
  });

  @override
  _AsyncVmMultiObserverState<Vm> createState() => _AsyncVmMultiObserverState<Vm>(
    liveDataGetters: liveDataGetters,
    builder: builder,
    predicate: predicate,
    preAsyncBuilder: preAsyncBuilder,
    distinctUntilChanged: distinctUntilChanged,
  );

}

class _AsyncVmMultiObserverState<Vm extends AsyncVm>
    extends State<AsyncVmMultiObserver<Vm>>
    implements Expirable
{
  final List<LiveData Function(Vm)> liveDataGetters;

  /// [List] in this lambda parameter has elements that returned by [liveDataGetters].
  /// The element order of [List] is same as element order of [liveDataGetters].
  final Widget Function(BuildContext, List) builder;

  /// [List] in this lambda parameter has same property as [builder]'s.
  final bool Function(List)? predicate;

  /// If it returns [Widget], it means the widget will be rebuilt using the returned [Widget].
  /// If it returns null, the old [Widget] will stay.
  final Widget? Function(BuildContext ctx, String key)? preAsyncBuilder;
  final bool distinctUntilChanged;

  List<LiveData>? liveDatas;
  List? currentDatas;

  Widget? incomingWidget;

  _AsyncVmMultiObserverState({
    required this.liveDataGetters,
    required this.builder,
    this.predicate,
    this.preAsyncBuilder,
    this.distinctUntilChanged = false,
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
    incomingWidget = null;
  }

  @override
  Widget build(BuildContext context) {
    if(liveDatas == null) {
      final vm = ViewModelProvider.of<Vm>(context);
      final vmPreAsyncTask = (preAsyncBuilder != null) ? (String key) {
        final newPreWidget = preAsyncBuilder!(this.context, key);
        //print("AsyncVmObserver.build() newPreWidget= $newPreWidget");
        if(newPreWidget != null) {
          setState(() {
            incomingWidget = newPreWidget;
            //print("AsyncVmObserver.build() incomingWidget SET");
          });
        }
      } : null;

      vm.addOnPreAsyncTask(this, vmPreAsyncTask);
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
            setState(() {
              incomingWidget = builder(context, currentDatas!);
            });
          }
        },
          distinctUntilChanged: distinctUntilChanged,
        );
      }
    }
    return incomingWidget ?? builder(context, currentDatas!);
  }
}