part of 'view_model.dart';


class _ViewModelStore extends InheritedWidget {
  _ViewModelStore({
    required List<ViewModel> viewModels,
    required List<ViewModel Function(BuildContext)> viewModelCreators,
    required Widget child,
    Key? key,
  }) :
        _viewModels = viewModels,
        _viewModelCreators = viewModelCreators,
        super(key: key, child: child);

  final List<ViewModel> _viewModels;
  final List<ViewModel Function(BuildContext)> _viewModelCreators;

  @override
  bool updateShouldNotify(_ViewModelStore oldWidget) => _viewModels != oldWidget._viewModels;
}

class ViewModelProvider extends StatefulWidget {
  final List<ViewModel Function(BuildContext)> creators;
  final Widget child;
  final Key? key;

  ViewModelProvider({
    required List<ViewModel Function(BuildContext)> creators,
    required this.child,
    this.key,
  }): this.creators = List.of(creators);

  @override
  _ViewModelProviderState createState() => _ViewModelProviderState(
    creators: creators,
    child: child,
    key: key,
  );

  static V of<V extends ViewModel>(BuildContext context) {
    final store = context.dependOnInheritedWidgetOfExactType<_ViewModelStore>();
    //print("store = $store");
    if(store == null) {
      throw "No _ViewModelStore in BuildContext $context";
    }
    final vms = store._viewModels;
    //print("vms = $vms");
    V? vm = vms.firstWhereOrNull((it) => it.runtimeType == V) as V?;
    //print("vm = $vm");
    if(vm == null) {
      final creators = store._viewModelCreators;
      //print("creators = $creators");
      int i = vms.length -1;
      int creatorsLen = creators.length;
      while(++i < creatorsLen) {
        //print("while creatorsLen = $creatorsLen i = $i");
        final newVm = creators[i](context);
        vms.add(newVm);
        if(newVm.runtimeType == V) {
          vm = newVm as V;
          break;
        }
      }
      //print("vm AKHIR = $vm");
      if(vm == null) {
        throw "No ViewModel type '$V' in BuildContext $context";
      }
    }
    return vm;
  }
}

class _ViewModelProviderState extends State<ViewModelProvider> {
  final List<ViewModel Function(BuildContext)> creators;
  final Widget child;
  final Key? key;
  List<ViewModel> _viewModels = [];

  _ViewModelProviderState({
    required this.creators,
    required this.child,
    this.key,
  });


  @override
  void dispose() {
    for(final vm in _viewModels) {
      vm._dispose();
    }
    _viewModels.clear();
    creators.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ViewModelStore(
      viewModelCreators: creators,
      viewModels: _viewModels,
      child: child,
      key: key,
    );
  }
}