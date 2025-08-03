import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:goalpost/models/task.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  
  // Fetch all tasks from the API
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        // Convert posts to tasks and add some sample completed tasks
        return jsonData.take(20).map((json) {
          final task = Task.fromJson({
            'id': json['id'],
            'title': json['title'],
            'body': json['body'],
            'completed': json['id'] % 3 == 0, // Make every 3rd task completed
            'createdAt': DateTime.now().subtract(
              Duration(days: json['id'] % 7)
            ).toIso8601String(),
          });
          return task;
        }).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create a new task
  Future<Task> createTask(String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'body': description,
          'userId': 1,
        }),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Task.fromJson({
          'id': jsonData['id'] ?? DateTime.now().millisecondsSinceEpoch,
          'title': title,
          'body': description,
          'completed': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } else {
        throw Exception('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update task completion status
  Future<Task> updateTask(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        return task;
      } else {
        throw Exception('Failed to update task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete a task
  Future<bool> deleteTask(int taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$taskId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}