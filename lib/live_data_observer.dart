import 'package:viewmodel/expirable.dart';
import 'package:flutter/cupertino.dart';

import 'live_data.dart';

class LiveDataObserver<T> extends StatefulWidget {
  final LiveData<T> liveData;
  final bool distinctUntilChanged;
  final Widget? Function(BuildContext, T?) builder;
  final Widget Function(BuildContext)? initBuilder;
  final bool Function(T?)? predicate;
  final bool isLiveDataOwner;
  /// If `true`, then when [liveData.value] is [T], [initBuilder] will be ignored even in initState.
  final bool immediatelyBuildState;

  LiveDataObserver({
    this.initBuilder,
    required this.builder,
    required this.liveData,
    this.predicate,
    this.distinctUntilChanged = false,
    this.isLiveDataOwner = false,
    this.immediatelyBuildState = false,
  });

  @override
  _LiveDataObserverState<T> createState() => _LiveDataObserverState(
    initBuilder: initBuilder,
    builder: builder,
    liveData: liveData,
    predicate: predicate,
    distinctUntilChanged: distinctUntilChanged,
    isLiveDataOwner: isLiveDataOwner,
    immediatelyBuildState: immediatelyBuildState,
  );
}

class _LiveDataObserverState<T>
    extends State<LiveDataObserver<T>>
    implements Expirable
{
  final LiveData<T> liveData;
  final bool distinctUntilChanged;
  final Widget? Function(BuildContext, T?) builder;
  final Widget Function(BuildContext)? initBuilder;
  final bool Function(T?)? predicate;
  bool isInit = true;
  final bool isLiveDataOwner;
  /// If `true`, then when [liveData.value] is [T], [initBuilder] will be ignored even in initState.
  final bool immediatelyBuildState;

  _LiveDataObserverState({
    required this.initBuilder,
    required this.builder,
    required this.liveData,
    required this.isLiveDataOwner,
    required this.immediatelyBuildState,
    required this.predicate,
    required this.distinctUntilChanged,
  }) {
    liveData.observe(this, (data) {
      //prind("liveData.observe data = $data");
      if(predicate == null || predicate!(data)) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _isActive = true;
    if(isInit) {
      Widget? initWidget;
      if(immediatelyBuildState && liveData.value is T) {
        initWidget = builder(context, liveData.value)
          ?? initBuilder?.call(context);
      } else {
        initWidget = initBuilder != null
            ? initBuilder!(context)
            : builder(context, liveData.value);
      }
      if(initWidget == null) {
        throw "Initial widget can't be null. This can happen when programmer doesn't provide `initBuilder` and `builder` returns null when `liveData.value` is null";
      }
      isInit = false;
      return initWidget;
    }
    final widget = builder(context, liveData.value);
    if(widget == null) {
      throw "`builder` can't return null widget.";
    }
    return widget;
  }

  bool _isActive = false;
  @override
  bool get isActive => _isActive;

  @override
  void dispose() {
    //prind("LiveDataObser '$runtimeType' is disposed");
    _isActive = false;
    if(isLiveDataOwner) {
      liveData.dispose();
    }
    super.dispose();
  }
}



//================ Multi LiveDataObserver ================

class MultiLiveDataObserver<T> extends StatefulWidget {
  final List<LiveData<T>> liveDataList;
  final bool distinctUntilChanged;

  /// Its [List<T?>] parameter has the same size as [liveDataList.length].
  /// Its elements' indices are same as [liveDataList] elements' indices.
  final Widget? Function(BuildContext, List<T?>) builder;
  final Widget Function(BuildContext)? initBuilder;

  /// Its [List<T?>] parameter has the same size as [liveDataList.length].
  /// Its elements' indices are same as [liveDataList] elements' indices.
  final bool Function(List<T?>)? predicate;
  final bool isLiveDataOwner;

  MultiLiveDataObserver({
    this.initBuilder,
    required this.builder,
    required this.liveDataList,
    this.predicate,
    this.distinctUntilChanged = false,
    this.isLiveDataOwner = false,
  });

  @override
  _MultiLiveDataObserverState<T> createState() => _MultiLiveDataObserverState(
    initBuilder: initBuilder,
    builder: builder,
    liveDataList: liveDataList,
    predicate: predicate,
    distinctUntilChanged: distinctUntilChanged,
    isLiveDataOwner: isLiveDataOwner,
  );
}


class _MultiLiveDataObserverState<T>
    extends State<MultiLiveDataObserver<T>>
    implements Expirable
{
  final List<LiveData<T>> liveDataList;
  final bool distinctUntilChanged;

  /// Its [List<T?>] parameter has the same size as [liveDataList.length].
  /// Its elements' indices are same as [liveDataList] elements' indices.
  final Widget? Function(BuildContext, List<T?>) builder;
  final Widget Function(BuildContext)? initBuilder;

  /// Its [List<T?>] parameter has the same size as [liveDataList.length].
  /// Its elements' indices are same as [liveDataList] elements' indices.
  final bool Function(List<T?>)? predicate;
  final bool isLiveDataOwner;

  bool isInit = true;

  _MultiLiveDataObserverState({
    this.initBuilder,
    required this.builder,
    required this.liveDataList,
    required this.isLiveDataOwner,
    this.predicate,
    this.distinctUntilChanged = false,
  }) {
    liveDataList.forEach((ld) {
      ld.observe(this, (data) {
        if(predicate == null || predicate!(getLiveDataValues())) {
          setState(() {});
        }
      });
    });
  }

  List<T?> getLiveDataValues() => liveDataList.map((e) => e.value)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    _isActive = true;
    if(isInit) {
      final initWidget = initBuilder != null
          ? initBuilder!(context)
          : builder(context, getLiveDataValues());
      if(initWidget == null) {
        throw "Initial widget can't be null. This can happen when programmer doesn't provide `initBuilder` and `builder` returns null when `liveData.value` is null";
      }
      isInit = false;
      return initWidget;
    }
    final widget = builder(context, getLiveDataValues());
    if(widget == null) {
      throw "`builder` can't return null widget.";
    }
    return widget;
  }

  bool _isActive = false;
  @override
  bool get isActive => _isActive;

  @override
  void dispose() {
    _isActive = false;
    if(isLiveDataOwner) {
      liveDataList.forEach((ld) => ld.dispose());
    }
    super.dispose();
  }
}