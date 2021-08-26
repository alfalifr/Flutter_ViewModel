
import 'package:flutter/material.dart';
import 'package:print_dart/print_dart.dart';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';

import 'expirable.dart';

class LiveData<T> implements Expirable {
  LiveData(this._value);
  T? _value;
  T? get value => _value;

  Map<Tuple2<Expirable, String>, Tuple2<void Function(T?), bool>>? _observers = {};
  List<void Function(T?)>? _foreverObservers;
  List<void Function(T?)>? _onceObservers;

  @override
  bool get isActive => _observers != null;

  bool _assertNotDisposed() {
    assert((){
      if(!isActive) {
        throw "LiveData '$this' has been disposed but still in use.";
      }
      return true;
    }());
    return true;
  }

  /// [distinctUntilChanged] `true` when [observer] is only notified when [_value]
  /// is different internally from the previous value. This means when setter of [value]
  /// in [MutableLiveData] invoked but with the same internal representation of [_value],
  /// [observer] won't be notified.
  void observe(
    Expirable observer,
    void Function(T?) onChange,
  {
    bool distinctUntilChanged = false,
    String tag = "",
  }) {
    _assertNotDisposed();
    final key = Tuple2(observer, tag);
    _observers![key] = Tuple2(onChange, distinctUntilChanged);
  }
  void observeForever(void Function(T?) onChange,) {
    _assertNotDisposed();
    if(_foreverObservers == null) {
      _foreverObservers = [];
    }
    _foreverObservers!.add(onChange);
  }
  void removeObserver(void Function(T?) onChange,) {
    _assertNotDisposed();
    if(_foreverObservers == null) return;
    if(!_foreverObservers!.remove(onChange)) {
      final entry = _observers!.entries.firstWhereOrNull((element) => element.value.item1 == onChange);
      if(entry != null) {
        _observers!.remove(entry.key);
      }
    }
  }
  void observeOnce(void Function(T?) onChange, { bool immediatelyGet = true }) {
    final v = _value;
    if(immediatelyGet && v is T) {
      onChange(v);
    } else {
      if(_onceObservers == null) {
        _onceObservers = [];
      }
      _onceObservers!.add(onChange);
    }
  }

  T getOrElse([T Function()? onElse]) {
    if(onElse == null && _value is! T) {
      throw "`value` of '$runtimeType' is not ready yet.";
    }
    return _value as T;
  }
/*
  Future<T> waitForValue() async {
    while(_value is! T) {}
    return _value as T;
  }
 */

  bool get hasActiveObserver => _observers?.length.compareTo(0) == 1;

  @mustCallSuper
  void dispose() {
    //prind("LiveData of `$runtimeType` is disposed");
    //_assertNotDisposed();
    _observers?.clear();
    _observers = null;
    _foreverObservers?.clear();
    _foreverObservers = null;
    _onceObservers?.clear();
    _onceObservers = null;
    _value = null;
  }

  void notifyObservers({T? oldValue, T? newValue}) {
    _assertNotDisposed();
    //prind("notifyObservers() type = $runtimeType oldValue= $oldValue newValue= $newValue _observers= $_observers");
    final removedKeys = <Tuple2<Expirable, String>>{};
    for(final key in _observers!.keys) {
      //print("notifyObservers() FOR AWAL key= $key");
      final observer = key.item1;
      //print("notifyObservers() FOR AWAL observer= $observer");
      if(observer.isActive) {
        final pair = _observers![key]!;
        //print("notifyObservers() FOR IF AWAL pair= $pair");
        if(!pair.item2 || oldValue != newValue) {
          pair.item1(_value);
        }
      } else {
        //_observers!.remove(observer);
        removedKeys.add(key);
      }
    }
    for(final key in removedKeys) {
      _observers!.remove(key);
    }
    if(_foreverObservers?.isNotEmpty == true) {
      for(final onChange in _foreverObservers!) {
        onChange(_value);
      }
    }
    if(_onceObservers?.isNotEmpty == true) {
      for(final onGet in _onceObservers!) {
        onGet(_value);
      }
      _onceObservers!.clear();
    }
  }

  @override
  String toString() => "LiveData<$T>(value=$value)";
}

class MutableLiveData<T> extends LiveData<T> {
  MutableLiveData([T? value]): super(value);
  set value(v) {
    if(!_isChanging) {
      _isChanging = true;
      final old = _value;
      _value = v;
      try {
        notifyObservers(oldValue: old, newValue: v);
      } catch(e, stack) {
        prine("Error during calling `notifyObservers` in set value of $this");
        prine(e);
        prine(stack);
      }
      _isChanging = false;
    }
  }

  /// A flag that marks whether this [LiveData] is changing
  /// its [_value] so this [LiveData] can prevent infinite loop
  /// when it comes to [MutableLiveData].
  bool _isChanging = false;

  bool get isChanging => _isChanging;


  void observeOther(LiveData<T> liveData) {
    liveData.observe(this, (data) {
      value = data;
    });
  }
}



/// Extended version of [LiveData] that can map [ChangeNotifier] change into
/// [LiveData.notifyObservers].
class ChangeNotifLiveData<T> extends LiveData<T> {
  ChangeNotifLiveData(
    this._notifier,
    this.onChange, {
    this.isNotifierOwner = false,
  }): super(onChange(_notifier)) {
    notifierCallback = () {
      if(isActive) {
        if(!_isChanging) {
          _isChanging = true;
          final oldValue = _value;
          _value = onChange(_notifier);
          notifyObservers(oldValue: oldValue, newValue: _value);
          _isChanging = false;
        }
      } else {
        _notifier.removeListener(notifierCallback);
      }
    };
    _notifier.addListener(notifierCallback);
  }

  /// A flag that marks whether this [ChangeNotifLiveData] is changing
  /// its [_value] so this [ChangeNotifLiveData] can prevent infinite loop
  /// when it comes to [MutableChangeNotifLiveData].
  bool _isChanging = false;

  final bool isNotifierOwner;
  ChangeNotifier _notifier;
  T? Function(ChangeNotifier) onChange;
  late final void Function() notifierCallback;

  void dispose() {
    super.dispose();
    _notifier.removeListener(notifierCallback);
    if(isNotifierOwner) {
      _notifier.dispose();
    }
  }

  @override
  String toString() => "LiveData<$T>(value=$_value)";
}


class MutableChangeNotifLiveData<T>
    extends ChangeNotifLiveData<T>
    implements MutableLiveData<T>
{
  MutableChangeNotifLiveData(
    ChangeNotifier notifier, {
    required T? Function(ChangeNotifier p1) getNotif,
    required this.setNotif,
    bool isNotifierOwner = false,
  }): super(notifier, getNotif, isNotifierOwner: isNotifierOwner,) {
    observe(this, (data) {
      if(!_isChanging) {
        _isChanging = true;
        setNotif(_notifier, data);
        _isChanging = false;
      }
    }, tag: "MutableChangeNotifLiveData<$T>");
  }

  @override
  set value(T? v) {
    if(!_isChanging) {
      _isChanging = true;
      final old = _value;
      _value = v;
      notifyObservers(oldValue: old, newValue: v);
      _isChanging = false;
    }
  }

  @override
  void observeOther(LiveData<T> liveData) {
    liveData.observe(this, (data) {
      value = data;
    });
  }

  final void Function(ChangeNotifier p1, T? value) setNotif;

  @override
  String toString() => "MutableLiveData<$T>(value=$_value)";

  @override
  bool get isChanging => _isChanging;
}