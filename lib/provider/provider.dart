import 'package:date_app/models/memory_model.dart';
import 'package:flutter/material.dart';

class MemoryProvider extends ChangeNotifier {
  List<MemoryModel> _memories = [];
  int _currentPage = 1;
  bool _hasNextPage = true;

  List<MemoryModel> get places => _memories;
  int get currentPage => _currentPage;
  bool get hasNextPage => _hasNextPage;

  void addPlaces(List<MemoryModel> newMemories, bool hasNext) {
    _memories.addAll(newMemories);
    _hasNextPage = hasNext;
    _currentPage++;
    notifyListeners();
  }

  void clear() {
    _memories = [];
    _currentPage = 1;
    _hasNextPage = true;
    notifyListeners();
  }
  
  void removePlaceById(int memoryId) {
    _memories.removeWhere((p) => p.id == memoryId);
    notifyListeners();
  }

  void addSinglePlace(MemoryModel newMemory) {
    _memories.insert(0, newMemory);
    notifyListeners();
  }

  void updatePlace(MemoryModel updated) {
    final index = _memories.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      _memories[index] = updated;
      notifyListeners();
    }
  }

}
