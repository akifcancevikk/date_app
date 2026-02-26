import 'package:date_app/models/memory_model.dart';
import 'package:flutter/material.dart';

class MemoryProvider extends ChangeNotifier {
  List<MemoryModel> _memories = [];
  int _currentPage = 1;
  bool _hasNextPage = true;

  // Expose read-only state for consumers.
  List<MemoryModel> get memories => _memories;
  int get currentPage => _currentPage;
  bool get hasNextPage => _hasNextPage;

  // Append new page results and advance pagination.
  void addMemories(List<MemoryModel> newMemories, bool hasNext) {
    _memories.addAll(newMemories);
    _hasNextPage = hasNext;
    _currentPage++;
    notifyListeners();
  }

  // Reset paging and cached memories.
  void clear() {
    _memories = [];
    _currentPage = 1;
    _hasNextPage = true;
    notifyListeners();
  }
  
  // Remove a memory by id.
  void removeMemoryById(int memoryId) {
    _memories.removeWhere((p) => p.id == memoryId);
    notifyListeners();
  }

  // Insert a new memory at the top of the list.
  void addMemory(MemoryModel newMemory) {
    _memories.insert(0, newMemory);
    notifyListeners();
  }

  // Replace a memory item with updated data.
  void updateMemory(MemoryModel updated) {
    final index = _memories.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      _memories[index] = updated;
      notifyListeners();
    }
  }

}
