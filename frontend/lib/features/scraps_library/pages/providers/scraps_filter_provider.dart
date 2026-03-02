import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../scrapnote/models/element_model.dart';

part 'scraps_filter_provider.g.dart';

/// Filter state for Scraps Library.
/// keepAlive so the filter persists across navigation.
/// null = show all element types.
@Riverpod(keepAlive: true)
class ScrapsFilter extends _$ScrapsFilter {
  @override
  ElementType? build() => null;

  void setFilter(ElementType? type) => state = type;
}
