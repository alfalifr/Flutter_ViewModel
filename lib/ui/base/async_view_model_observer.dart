import 'package:viewmodel/domain/model/result.dart';
import 'package:flutter/material.dart';

import 'async_vm.dart';
import 'expirable.dart';
import 'live_data.dart';
import 'view_model.dart';


class AsyncVmObserver<Vm extends AsyncViewModel, V> extends StatefulWidget {
  final LiveData<V> Function(Vm) liveDataGetter;
  final Widget Function(BuildContext, V?) builder;
  final bool Function(V?)? predicate;

  /// If it returns [Widget], it means the widget will be rebuilt using the returned [Widget].
  /// If it returns null, the old [Widget] will stay.
  final Widget? Function(BuildContext ctx, String key)? preAsyncBuilder;

  /// If it returns [Widget], it means the widget will be rebuilt using the returned [Widget].
  /// If it returns null, the old [Widget] will stay.
  final Widget? Function(BuildContext ctx, String key)? postAsyncBuilder;

  /// If it returns [Widget], it means the widget will be rebuilt using the returned [Widget].
  /// If it returns null, the old [Widget] will stay.
  final Widget? Function(BuildContext ctx, String key, Fail failure)? onFailBuilder;
  final bool distinctUntilChanged;

  /// If this not null and not empty, then [preAsyncBuilder] and [onFailBuilder]
  /// will be filtered to receive keys in this [vmTaskKeys].
  final List<String>? vmTaskKeys;
  final Vm? vm;

  AsyncVmObserver({
    required this.liveDataGetter,
    required this.builder,
    this.vmTaskKeys,
    this.predicate,
    this.preAsyncBuilder,
    this.postAsyncBuilder,
    this.onFailBuilder,
    this.distinctUntilChanged = false,
    /// This way, this.[AsyncVmObserver] won't be busy of looking for [Vm] in parent tree.
    this.vm,
  });

  @override
  _AsyncVmObserverState<Vm, V> createState() => _AsyncVmObserverState<Vm, V>(
    vm: vm,
    liveDataGetter: liveDataGetter,
    builder: builder,
    predicate: predicate,
    preAsyncBuilder: preAsyncBuilder,
    postAsyncBuilder: postAsyncBuilder,
    onFailBuilder: onFailBuilder,
    distinctUntilChanged: distinctUntilChanged,
    vmTaskKeys: vmTaskKeys,
  );

}

class _AsyncVmObserverState<Vm extends AsyncViewModel, V>
    extends State<AsyncVmObserver<Vm, V>>
    implements Expirable
{
  final LiveData<V> Function(Vm) liveDataGetter;
  final Widget Function(BuildContext, V?) builder;
  final bool Function(V?)? predicate;
  final bool distinctUntilChanged;
  final List<String>? vmTaskKeys;
  Vm? vm;
  LiveData<V>? _liveData;

  final Widget? Function(BuildContext ctx, String key)? preAsyncBuilder;
  final Widget? Function(BuildContext ctx, String key)? postAsyncBuilder;
  final Widget? Function(BuildContext ctx, String key, Fail failure)? onFailBuilder;

  Widget? incomingWidget;

  _AsyncVmObserverState({
    required this.liveDataGetter,
    required this.builder,
    required this.vmTaskKeys,
    /// This way, this.[AsyncVmObserver] won't be busy of looking for [Vm] in parent tree.
    required this.vm,
    required this.predicate,
    required this.preAsyncBuilder,
    required this.postAsyncBuilder,
    required this.onFailBuilder,
    required this.distinctUntilChanged,
  });

  bool _isActive = true;
  @override
  bool get isActive => _isActive;

  @override
  void dispose(){
    super.dispose();
    _isActive = false;
    _liveData = null;
    vm = null;
  }

  @override
  Widget build(BuildContext context) {
    if(_liveData == null) {
      final vm = this.vm ??= ViewModelProvider.of<Vm>(context);
      final vmPreAsyncTask = (preAsyncBuilder != null) ? (String key) {
        if(vmTaskKeys?.isEmpty != false || vmTaskKeys!.contains(key)) {
          final newPreWidget = preAsyncBuilder!(this.context, key);
          //print("AsyncVmObserver.build() newPreWidget= $newPreWidget");
          if(newPreWidget != null) {
            setState(() {
              incomingWidget = newPreWidget;
              //print("AsyncVmObserver.build() incomingWidget SET");
            });
          }
        }
      } : null;
      final vmPostAsyncTask = (postAsyncBuilder != null) ? (String key) {
        if(vmTaskKeys?.isEmpty != false || vmTaskKeys!.contains(key)) {
          final newPreWidget = postAsyncBuilder!(this.context, key);
          //print("AsyncVmObserver.build() newPreWidget= $newPreWidget");
          if(newPreWidget != null) {
            setState(() {
              incomingWidget = newPreWidget;
              //print("AsyncVmObserver.build() incomingWidget SET");
            });
          }
        }
      } : null;
      final vmOnFailTask = (onFailBuilder != null) ? (String key, Fail failure) {
        if(vmTaskKeys?.isEmpty != false || vmTaskKeys!.contains(key)) {
          final newPreWidget = onFailBuilder!(this.context, key, failure);
          //print("AsyncVmObserver.build() newPreWidget= $newPreWidget");
          if(newPreWidget != null) {
            setState(() {
              incomingWidget = newPreWidget;
              //print("AsyncVmObserver.build() incomingWidget SET");
            });
          }
        }
      } : null;

      vm.addOnPreAsyncTask(this, vmPreAsyncTask);
      vm.addOnPostAsyncTask(this, vmPostAsyncTask);
      vm.addOnFailTask(this, vmOnFailTask);
      _liveData = liveDataGetter(vm);
      _liveData!.observe(this, (data) {
        if(predicate == null || predicate!(data)) {
          setState(() {
            incomingWidget = builder(context, _liveData!.value);
          });
        }
      },
        distinctUntilChanged: distinctUntilChanged,
      );
    }
    return incomingWidget ?? builder(context, _liveData!.value);
  }
}