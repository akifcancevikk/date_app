import 'package:date_app/models/memory_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memory_provider.g.dart';

class MemoriesState {
  final List<MemoryModel> items;
  final int currentPage;
  final bool hasNextPage;
  final bool isLoadingMore;

  const MemoriesState({
    required this.items,
    required this.currentPage,
    required this.hasNextPage,
    required this.isLoadingMore,
  });

  const MemoriesState.initial()
      : items = const [],
        currentPage = 1,
        hasNextPage = true,
        isLoadingMore = false;

  MemoriesState copyWith({
    List<MemoryModel>? items,
    int? currentPage,
    bool? hasNextPage,
    bool? isLoadingMore,
  }) {
    return MemoriesState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@riverpod
class Memories extends _$Memories {
  @override
  MemoriesState build() => const MemoriesState.initial();

  void reset() => state = const MemoriesState.initial();

  void setLoadingMore(bool value) {
    state = state.copyWith(isLoadingMore: value);
  }

  void setFirstPage(List<MemoryModel> list, bool hasNext) {
    final uniqueFirstPage = _dedupeById(list);
    state = state.copyWith(
      items: uniqueFirstPage,
      currentPage: 2,
      hasNextPage: hasNext,
      isLoadingMore: false,
    );
  }

  void appendPage(List<MemoryModel> list, bool hasNext) {
    final merged = [...state.items, ...list];
    final uniqueMerged = _dedupeById(merged);
    state = state.copyWith(
      items: uniqueMerged,
      currentPage: state.currentPage + 1,
      hasNextPage: hasNext,
      isLoadingMore: false,
    );
  }

  void addMemory(MemoryModel memory) {
    final merged = [memory, ...state.items];
    state = state.copyWith(items: _dedupeById(merged));
  }

  void updateMemory(MemoryModel updated) {
    final updatedItems =
        state.items.map((m) => m.id == updated.id ? updated : m).toList();
    state = state.copyWith(items: updatedItems);
  }

  void removeMemoryById(int memoryId) {
    state = state.copyWith(
      items: state.items.where((m) => m.id != memoryId).toList(),
    );
  }
}

List<MemoryModel> _dedupeById(List<MemoryModel> memories) {
  final byId = <int, MemoryModel>{};
  for (final memory in memories) {
    byId[memory.id] = memory;
  }
  return byId.values.toList();
}
