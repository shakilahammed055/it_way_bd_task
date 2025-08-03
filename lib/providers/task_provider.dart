import 'package:flutter/foundation.dart';
import 'package:goalpost/models/task.dart';
import 'package:goalpost/services/api_service.dart';

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get completed tasks
  List<Task> get completedTasks => _tasks.where((task) => task.completed).toList();
  
  // Get pending tasks
  List<Task> get pendingTasks => _tasks.where((task) => !task.completed).toList();

  // Get task counts
  int get totalTasks => _tasks.length;
  int get completedCount => completedTasks.length;
  int get pendingCount => pendingTasks.length;

  // Fetch tasks from API
  Future<void> fetchTasks() async {
    _setLoading(true);
    _clearError();
    
    try {
      final tasks = await _apiService.fetchTasks();
      _tasks = tasks;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Add a new task
  Future<void> addTask(String title, String description) async {
    if (title.trim().isEmpty) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final newTask = await _apiService.createTask(title.trim(), description.trim());
      
      // Add the new task with a unique ID based on current timestamp
      final taskWithUniqueId = newTask.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
      );
      
      _tasks.insert(0, taskWithUniqueId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(Task task) async {
    _clearError();
    
    try {
      final updatedTask = task.copyWith(completed: !task.completed);
      
      // Update locally first for immediate UI feedback
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
      
      // Then update on the server
      await _apiService.updateTask(updatedTask);
    } catch (e) {
      // Revert the change if API call fails
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
      _setError(e.toString());
    }
  }

  // Delete a task
  Future<void> deleteTask(Task task) async {
    _clearError();
    
    try {
      // Remove locally first for immediate UI feedback
      _tasks.removeWhere((t) => t.id == task.id);
      notifyListeners();
      
      // Then delete from the server
      await _apiService.deleteTask(task.id);
    } catch (e) {
      // Add the task back if API call fails
      _tasks.add(task);
      notifyListeners();
      _setError(e.toString());
    }
  }

  // Clear all completed tasks
  Future<void> clearCompletedTasks() async {
    final completedTasks = _tasks.where((task) => task.completed).toList();
    
    for (final task in completedTasks) {
      await deleteTask(task);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}