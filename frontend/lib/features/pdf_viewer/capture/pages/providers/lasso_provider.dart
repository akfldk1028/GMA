import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lasso_provider.g.dart';

/// Global lasso mode state — true when freehand lasso capture is active.
/// Mutually exclusive with drawing mode and capture mode.
@Riverpod(keepAlive: true)
class LassoMode extends _$LassoMode {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setActive(bool v) => state = v;
}
