import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'expirable.dart';
import 'live_data.dart';

part 'view_model_provider.dart';
part 'view_model_observer.dart';


abstract class ViewModel implements Expirable {
  bool _isActive = true;
  @override
  bool get isActive => _isActive;

  /// The list of all [LiveData] this [ViewModel] has.
  /// This getter is useful for the [LiveData] automatic disposal
  /// when this [ViewModel] get disposed ([_dispose] is invoked).
  List<LiveData<dynamic>> get liveDatas;

  void _dispose() {
    _isActive = false;
    for(final ld in liveDatas) {
      ld.dispose();
    }
    dispose();
  }
  void dispose() {}
}

