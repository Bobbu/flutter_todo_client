import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../main_globals.dart';

class TodoEditPage extends StatelessWidget {
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  TodoEditPage({super.key});

  void _onSave(BuildContext context, Todo todo) async {
    todo.item = textController.text;
    final TodoService ts = TodoService();
    try {
      await ts.saveTodo(todo); // ingore return value since a guranteed update
      if (!context.mounted) {
        debugPrint('BuildContext not mounted.');
      } else {
        Navigator.pop(context, todo);
      }
    } on TodoServiceException catch (ex) {
      final ScaffoldMessengerState? scaffold = appScaffoldKey.currentState;
      final snackBar = SnackBar(content: Text(ex.message));
      if (scaffold != null) {
        scaffold.showSnackBar(snackBar);
      } else {
        debugPrint(ex.message);
      }
    }
  }

  void _onCancel(BuildContext context, Todo todo) {
    Navigator.pop(context, todo);
  }

  @override
  Widget build(BuildContext context) {
    Todo todo = ModalRoute.of(context)!.settings.arguments as Todo;
    textController.text = todo.item;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editing todo'),
        leading: BackButton(onPressed: () {
          _onCancel(context, todo);
        }),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              focusNode: focusNode,
              controller: textController,
              decoration: InputDecoration(
                  hintText: 'existing todo',
                  labelText: "Edit existing todo",
                  suffixIcon: IconButton(
                      onPressed: () => textController.clear(),
                      icon: const Icon(Icons.clear))),
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _onCancel(context, todo);
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(
                width: 10.0,
              ),
              ElevatedButton(
                onPressed: () {
                  _onSave(context, todo);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
