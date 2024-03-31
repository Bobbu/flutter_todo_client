import 'dart:io';
import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'dart:convert'; // as convert;
import 'package:http/http.dart' as http;

/// Each of the methds in the TodoService can potentially throw a
/// TodoServiceException.
class TodoServiceException extends HttpException {
  TodoServiceException(super.message);
}

class TodoService {
  static const todosUrlString = 'http://127.0.0.1:8000/todos';

  ////////////////////////////////////////////////////////////////////////////
  ///
  /// getAll
  ///
  /// On error, will throw TodoServiceException
  ///
  Future<List<Todo>> getAll() async {
    // comment out the future delay once happy with simulated slowness,
    // but keep around in the event we want to test again later.
    // await Future.delayed(const Duration(seconds: 2), () {
    //   debugPrint('2 seconds have passed.');
    // });

    final Uri todosUrl = Uri.parse(todosUrlString);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(todosUrl);

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      List<Todo> todos =
          List<Todo>.from(l.map((model) => Todo.fromJson(model)));
      return todos;
    } else {
      final message =
          'Could not get all todos (status: ${response.statusCode}).';
      debugPrint(message);
      throw TodoServiceException(message);
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  ///
  /// getOne
  ///
  /// Tries to find the first todo that matches the presented ID.
  ///
  /// On error, will throw TodoServiceException
  ///
  Future<Todo> getOne(int id) async {
    final Uri todoUrl = Uri.parse('$todosUrlString/$id');
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(todoUrl);

    if (response.statusCode == 200) {
      Todo todo = Todo.fromJson(json.decode(response.body));
      return todo;
    } else {
      final message =
          'Could not get todo with ID $id (status: ${response.statusCode}).';
      debugPrint(message);
      throw TodoServiceException(message);
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  ///
  /// saveTodo
  ///
  /// If the todo presented does not have an ID, a create will be attempted, and
  /// the resulting todo will be complete with a newly assigned ID.  If the ID
  /// is present, then an update will be attempted and the resulting todo will be
  /// identical to what was presented.
  ///
  /// On error, will throw TodoServiceException
  ///
  Future<Todo> saveTodo(Todo todo) async {
    dynamic response;
    Uri todoUrl;
    const headers = {'Content-type': 'application/json'};
    final body = json.encode(todo);

    if (todo.id == null) {
      todoUrl = Uri.parse(todosUrlString);
      response = await http.post(todoUrl, headers: headers, body: body);
    } else {
      todoUrl = Uri.parse('$todosUrlString/${todo.id}');
      response = await http.put(todoUrl, headers: headers, body: body);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      Todo todo = Todo.fromJson(json.decode(response.body));
      return todo;
    } else {
      final message =
          'Could not save the todo (status: ${response.statusCode}).';
      debugPrint(message);
      throw TodoServiceException(message);
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  ///
  /// deleteTodo
  ///
  /// Tries to delete the first todo that matches the presented ID. Will return
  /// it if successful.
  ///
  /// On error, will throw TodoServiceException
  ///
  Future<Todo> deleteTodo(Todo todoToDelete) async {
    final Uri todoUrl = Uri.parse('$todosUrlString/${todoToDelete.id}');
    // Await the http get response, then decode the json-formatted response.
    var response = await http.delete(todoUrl);

    if (response.statusCode == 200) {
      return todoToDelete;
    } else {
      final message =
          'Could not delete the todo with ID ${todoToDelete.id} (status: ${response.statusCode}).';
      debugPrint(message);
      throw TodoServiceException(message);
    }
  }
}
