import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'capture_provider.g.dart';

/// Global capture mode state — true when area capture is active.
/// Mutually exclusive with drawing mode.
@Riverpod(keepAlive: true)
class CaptureMode extends _$CaptureMode {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setActive(bool v) => state = v;
}
