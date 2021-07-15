part of 'view_model.dart';


class ViewModelObserver<Vm extends ViewModel, V> extends StatefulWidget {
  final LiveData<V> Function(Vm) liveDataGetter;
  final Widget Function(BuildContext, V?) builder;
  final bool Function(V?)? predicate;
  final bool distinctUntilChanged;
  final Vm? vm;

  ViewModelObserver({
    required this.liveDataGetter,
    required this.builder,
    this.vm,
    this.predicate,
    this.distinctUntilChanged = false,
  });

  @override
  _ViewModelObserverState<Vm, V> createState() => _ViewModelObserverState<Vm, V>(
    vm: vm,
    liveDataGetter: liveDataGetter,
    builder: builder,
    predicate: predicate,
    distinctUntilChanged: distinctUntilChanged,
  );

}

class _ViewModelObserverState<Vm extends ViewModel, V>
    extends State<ViewModelObserver<Vm, V>>
    implements Expirable
{
  final LiveData<V> Function(Vm) liveDataGetter;
  final Widget Function(BuildContext, V?) builder;
  final bool Function(V?)? predicate;
  final bool distinctUntilChanged;
  Vm? vm;
  LiveData<V>? _liveData;

  _ViewModelObserverState({
    required this.liveDataGetter,
    required this.builder,
    required this.distinctUntilChanged,
    required this.vm,
    this.predicate,
  });

  bool _isActive = true;
  @override
  bool get isActive => _isActive;

  @override
  void dispose(){
    _isActive = false;
    super.dispose();
    _liveData = null;
    vm = null;
  }

  @override
  Widget build(BuildContext context) {
    if(_liveData == null) {
      final vm = this.vm ??= ViewModelProvider.of<Vm>(context);
      _liveData = liveDataGetter(vm);
      _liveData!.observe(this, (data) {
        if(predicate == null || predicate!(data)) {
          setState(() {});
        }
      },
        distinctUntilChanged: distinctUntilChanged,
      );
    }
    return builder(context, _liveData!.value);
  }
}