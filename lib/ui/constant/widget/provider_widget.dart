import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// A widget that provides a value passed through a provider as a parameter of the build function.
abstract class ProviderWidget<T> extends Widget {
  final bool reactive;

  const ProviderWidget({Key? key, this.reactive = true}) : super(key: key);

  @protected
  Widget build(BuildContext context, T changeNotifier);

  @override
  _DataProviderElement<T> createElement() => _DataProviderElement<T>(this);
}

class _DataProviderElement<T> extends ComponentElement {
  _DataProviderElement(ProviderWidget widget) : super(widget);

  @override
  ProviderWidget get widget => super.widget as ProviderWidget<dynamic>;

  @override
  Widget build() =>
      widget.build(this, Provider.of<T>(this, listen: widget.reactive));

  @override
  void update(ProviderWidget newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    rebuild();
  }
}
