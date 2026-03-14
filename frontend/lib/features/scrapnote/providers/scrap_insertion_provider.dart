import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/scrap_insertion_service.dart';

part 'scrap_insertion_provider.g.dart';

/// Provides a singleton [ScrapInsertionService] instance.
@Riverpod(keepAlive: true)
ScrapInsertionService scrapInsertionService(Ref ref) {
  final service = ScrapInsertionService();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Tracks the currently active scrap proposal for the confirm popup.
///
/// Listens to the [ScrapInsertionService.proposals] stream and exposes
/// the latest proposal (or null if none is active).
@riverpod
class ActiveScrapProposal extends _$ActiveScrapProposal {
  StreamSubscription<Object>? _subscription;

  @override
  Object? build() {
    final service = ref.watch(scrapInsertionServiceProvider);
    _subscription?.cancel();
    _subscription = service.proposals.listen((proposal) {
      state = proposal;
    });
    ref.onDispose(() => _subscription?.cancel());
    return null;
  }

  /// Clear the active proposal (after accept/reject).
  void clear() {
    state = null;
  }
}
